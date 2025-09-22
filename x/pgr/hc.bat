@echo off


psql gtfsdb^
 -c 'select file from map.mvts;' --csv^
 -L './test.csv'^
 -U akaki^
 -p 5432