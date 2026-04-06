if [ $# -eq 0 ]; then
  echo "Usage: run-loader.sh <country> <region>"
  exit 1
fi

if [ "$(uname -s)" = "Linux" ] && ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed on this Linux system. Please install Docker and try again."
  exit 1
fi

echo "Loading data of $1 into database..."
mkdir db
wget https://download.geofabrik.de/$2/$1-latest.osm.pbf
echo "Converting data into .osm.bz2 format..."
docker run --rm -v ./:/opt/op tderflinger/overpass-immu-docker  /usr/bin/osmium cat /opt/op/$1-latest.osm.pbf -o /opt/op/$1.osm.bz2
echo "Testing integrity of .osm.bz2 file..."
docker run --rm -v ./:/opt/op tderflinger/overpass-immu-docker  /usr/bin/bzip2 --test /opt/op/$1.osm.bz2
echo "Importing data into database..."
docker run --rm -v ./:/opt/op/data -v ./db:/opt/op/db tderflinger/overpass-immu-docker sh -c "/usr/bin/bunzip2 < /opt/op/data/$1.osm.bz2 | /opt/op/bin/update_database --db-dir=/opt/op/db --meta=no"
echo "Import finished. Running update_database with rules/areas.osm3s to create areas..."
docker run --rm -it -v ./rules:/opt/op/rules -v ./db:/opt/op/db tderflinger/overpass-immu-docker sh -c "/opt/op/bin/osm3s_query --db-dir=/opt/op/db --progress --rules </opt/op/rules/areas.osm3s"
echo "Done."
