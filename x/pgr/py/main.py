# requires: pip install psycopg2-binary networkx munkres
import os
import psycopg2
import networkx as nx
from munkres import Munkres

DSN = os.environ.get("DATABASE_URL")  # e.g. postgres://user:pass@host:5432/db
if not DSN:
    raise SystemExit("set DATABASE_URL env var")

conn = psycopg2.connect(DSN)
cur = conn.cursor()

# load segments and route mapping
cur.execute("select segment_id, st_astext(st_transform(geom,3857)) from tmp.segments")
segments = {sid: wkt for sid, wkt in cur.fetchall()}

cur.execute("select segment_id, array_agg(route_id order by route_id) from tmp.route_segments group by segment_id")
seg_routes = {row[0]: row[1] for row in cur.fetchall()}

# build adjacency by geometric touch (segments that share endpoints or intersect)
# simple approach: compute bbox intersection via DB to get edges
cur.execute("""
select s1.segment_id, s2.segment_id
from tmp.segments s1
join tmp.segments s2 on s1.segment_id < s2.segment_id
where st_dwithin(st_transform(s1.geom,3857)::geography, st_transform(s2.geom,3857)::geography, 1.0)
""")
edges = cur.fetchall()

G = nx.Graph()
G.add_nodes_from(segments.keys())
G.add_edges_from(edges)

# helper: make deterministic initial order for a segment's routes
def initial_order(route_list):
    return sorted(route_list)

munkres = Munkres()

# result map: (segment_id, route_id) -> lane index
assignments = {}

# process each connected component
for comp in nx.connected_components(G):
    # pick a start segment (smallest id)
    comp_sub = G.subgraph(comp)
    start = min(comp_sub.nodes())
    # BFS order
    bfs_nodes = list(nx.bfs_tree(comp_sub, start))
    prev_order_map = None  # route -> lane for previous segment

    for seg in bfs_nodes:
        routes = seg_routes.get(seg, [])
        if not routes:
            continue
        cur_order = initial_order(routes)  # baseline ordering
        # if no previous, assign sequential lanes 0..n-1
        if prev_order_map is None:
            for i, r in enumerate(cur_order):
                assignments[(seg, r)] = i
            prev_order_map = {r: i for i, r in enumerate(cur_order)}
            continue

        # build cost matrix between prev_order_map keys and cur_order candidates
        prev_routes = list(prev_order_map.keys())
        # we want to align common routes to minimize lane change
        # rows = prev_routes, cols = cur_order (we will allow insertion of new routes)
        n = max(len(prev_routes), len(cur_order))
        cost_matrix = [[1000]*n for _ in range(n)]
        # fill costs for matching existing prev->cur candidates
        for i, pr in enumerate(prev_routes):
            for j, cr in enumerate(cur_order):
                if pr == cr:
                    cost = abs(prev_order_map[pr] - j)  # minimize position change
                else:
                    cost = 5 + abs(prev_order_map[pr] - j)  # penalty if not same route
                cost_matrix[i][j] = cost
        # allow unmatched new routes: assign moderate cost from virtual prev slots
        # run hungarian
        indexes = munkres.compute(cost_matrix)
        # build mapping from cur route to lane by trying to preserve prev lanes where possible
        lane_map = {}
        used_lanes = set()
        # first, assign matched pairs
        for i, j in indexes:
            if i < len(prev_routes) and j < len(cur_order):
                pr = prev_routes[i]
                cr = cur_order[j]
                # prefer previous lane
                lane = prev_order_map.get(pr, j)
                lane_map[cr] = lane
                used_lanes.add(lane)
        # assign leftover cur routes compactly to next free lanes
        next_lane = 0
        for cr in cur_order:
            if cr in lane_map:
                continue
            while next_lane in used_lanes:
                next_lane += 1
            lane_map[cr] = next_lane
            used_lanes.add(next_lane)
        # save assignments
        for r, lane in lane_map.items():
            assignments[(seg, r)] = lane
        prev_order_map = lane_map

# write back to tmp.segment_lanes (truncate and insert)
cur.execute("truncate table tmp.segment_lanes")
rows = [(seg, r, lane) for (seg, r), lane in assignments.items()]
cur.executemany("insert into tmp.segment_lanes(segment_id, route_id, lane) values (%s,%s,%s)", rows)
conn.commit()
cur.close()
conn.close()

print("done. assigned", len(rows), "entries")