@echo off


psql ^
-c 'select file from map.mvts;' --csv ^
-L './test.csv' ^
-d gtfsdb ^
-U akaki