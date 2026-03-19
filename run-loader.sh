if [ $# -eq 0 ]; then
  echo "Usage: run-loader.sh <country> <region>"
  exit 1
fi

echo "Loading data of $1 into database..."
wget https://download.geofabrik.de/$2/$1-latest.osm.pbf
docker run --rm -v ./:/opt/op tderflinger/overpass-immu-docker  /usr/bin/osmium cat /opt/op/$1-latest.osm.pbf -o /opt/op/$1.osm.bz2
docker run --rm -v ./:/opt/op tderflinger/overpass-immu-docker  /usr/bin/bzip2 --test /opt/op/$1.osm.bz2
docker run --rm -v ./:/opt/op tderflinger/overpass-immu-docker sh -c "/usr/bin/bunzip2 < /opt/op/$1.osm.bz2 | /opt/op/binaries/update_database --db-dir=/opt/op/db --meta=no"
docker run --rm -it -v ./:/opt/op tderflinger/overpass-immu-docker sh -c "/opt/op/binaries/osm3s_query --db-dir=/opt/op/db --progress --rules </opt/op/rules/areas.osm3s"
echo "Done."
