

psql gtfsdb -c "select z, x, y, encode(data, 'hex') from map.mvts;" --csv -U akaki -p 5432 -q -o './mvts.csv'



# certutil -decodehex './mvts.csv' './mvts_decodedcsv'


  # for /f %%d in ('./mvts.csv') do (
  #   echo %%d
  # )