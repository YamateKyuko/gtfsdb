with envelope as (st_tileenvelope(12, 3635, 1612))
select st_asmvt((
  select st_asmvtgeom(
    st_transform(geom, 3857),
    envelope
  ) from map.results, envelope),
  "mvtpolys"

)

-- 12, 3635, 1612