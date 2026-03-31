#!/usr/bin/env bash
set -euo pipefail

nohup /overpass/bin/dispatcher --osm-base --db-dir=/overpass/db &
nohup /overpass/bin/dispatcher --areas --db-dir=/overpass/db &

exec httpd-foreground -c "LoadModule cgid_module modules/mod_cgid.so"
