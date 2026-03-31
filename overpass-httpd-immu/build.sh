#!/usr/bin/env bash
set -euo pipefail

wget https://dev.overpass-api.de/releases/osm-3s_latest.tar.gz
tar -xzf osm-3s_latest.tar.gz
BUILD_DIR=$(tar -tzf osm-3s_latest.tar.gz | awk -F/ 'NR==1{first=$1} END{print first}')

mkdir -p overpass
mv "$BUILD_DIR/html" overpass/

pushd "$BUILD_DIR"
CPPFLAGS="-D_LARGEFILE64_SOURCE -D_GNU_SOURCE" \
	./configure --disable-dependency-tracking --enable-lz4 --prefix="$(pwd)/../overpass"
make -j 2
make install
popd

pushd overpass
mkdir -p db
for f in bin/* cgi-bin/*; do
	[ -f "$f" ] || continue
	if [ "$(od -An -tx1 -N4 "$f" | tr -d ' \n')" = "7f454c46" ]; then
		strip "$f"
	fi
done
popd

