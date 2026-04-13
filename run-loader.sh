if [ $# -ne 2 ] && [ $# -ne 3 ]; then
  echo "Usage: run-loader.sh <country> <region>"
  echo "Optional: run-loader.sh <subregion> <country> <region>"
  echo ""
  echo "Names for <country>, <subregion>, and <region> should match the ones used in Geofabrik URLs. For example, for Germany, you can use 'germany' as <country>, 'bayern' as <subregion>, and 'europe' as <region>."
  echo "Check at Geofabrik: https://download.geofabrik.de for the correct names to use."
  exit 1
fi

if [ "$(uname -s)" = "Linux" ] && ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed on this Linux system. Please install Docker and try again."
  exit 1
fi

echo "Downloading data of $1 from Geofabrik..."
mkdir -p db

if [ $# -eq 3 ]; then
  download_url="https://download.geofabrik.de/$3/$2/$1-latest.osm.pbf"
else
  download_url="https://download.geofabrik.de/$2/$1-latest.osm.pbf"
fi

if [ ! -f "$1-latest.osm.pbf" ]; then
  wget "$download_url"
else
  echo "Skipping download, $1-latest.osm.pbf already exists."
fi

echo "Converting data into .osm.bz2 format..."
docker run --rm -v ./:/opt/op tderflinger/overpass-immu-docker  /usr/bin/osmium cat /opt/op/$1-latest.osm.pbf -o /opt/op/$1.osm.bz2
echo "Testing integrity of .osm.bz2 file..."
docker run --rm -v ./:/opt/op tderflinger/overpass-immu-docker  /usr/bin/bzip2 --test /opt/op/$1.osm.bz2
echo "Importing data into database..."
docker run --rm -v ./:/opt/op/data -v ./db:/opt/op/db tderflinger/overpass-immu-docker sh -c "/usr/bin/bunzip2 < /opt/op/data/$1.osm.bz2 | /opt/op/bin/update_database --db-dir=/opt/op/db --meta=no"
echo "Import finished. Running update_database with rules/areas.osm3s to create areas..."
docker run --rm -it -v ./rules:/opt/op/rules -v ./db:/opt/op/db tderflinger/overpass-immu-docker sh -c "/opt/op/bin/osm3s_query --db-dir=/opt/op/db --progress --rules </opt/op/rules/areas.osm3s"
echo "Done."
