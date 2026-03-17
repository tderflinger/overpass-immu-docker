# overpass-immu-docker

This is a specialized Docker container for querying OSM using Overpass.
The use case is querying the OSM data with Overpass locally. 

Download the data you want to query as `.pbf` files and convert them to the database structure the
Overpass CLI can query. Run Overpass queries against the data locally without
relying on any public Overpass API server.

The main idea is to have the OSM data linked via Docker volumes to the Overpass application.
The docker container should be immutable (that is where the name comes from).

For simplicity, there is no data update mechanism included.

## Run

Interactive bash:

docker run --rm -it -v ./:/opt/op overpass-immu-docker /bin/bash

Run Osmium:

docker run --rm -v ./:/opt/op overpass-immu-docker  /usr/bin/osmium cat /opt/op/monaco-latest.osm.pbf -o /opt/op/monaco.osm.bz2

docker run --rm -v ./:/opt/op overpass-immu-docker  /usr/bin/bzip2 --test /opt/op/monaco.osm.bz2

docker run --rm -v ./:/opt/op overpass-immu-docker sh -c "/usr/bin/bunzip2 < /opt/op/monaco.osm.bz2 | /opt/op/binaries/update_database --db-dir=/opt/op/db --meta=no"

docker run --rm -it -v ./:/opt/op overpass-immu-docker sh -c "/opt/op/binaries/osm3s_query --db-dir=/opt/op/db --progress --rules </opt/op/rules/areas.osm3s"

docker run --rm -it -v ./:/opt/op overpass-immu-docker  /opt/op/binaries/osm3s_query --db-dir=/opt/op/db

## References

- Overpass API: https://github.com/drolbr/Overpass-API

- Setting up an Overpass API server - how hard can it be: https://www.openstreetmap.org/user/SomeoneElse/diary/408252


## License

This repository as such is licensed as MIT.

It contains the following applications licensed as AGPL-3.0:  `binaries/osm3s_query` and `binaries/update_database` and `rules/areas.osm3s` from [Overpass API](https://github.com/drolbr/Overpass-API).
