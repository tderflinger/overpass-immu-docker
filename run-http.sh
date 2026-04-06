echo "Starting Overpass API with HTTP interface..."
cd db
rm osm3s_* 2>/dev/null
cd ..
docker run -d -v ./db:/overpass/db -p 8080:80 tderflinger/overpass-httpd-immu:latest
echo "Overpass API is running at http://localhost:8080/api"
