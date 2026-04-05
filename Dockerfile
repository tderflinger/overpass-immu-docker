FROM ubuntu:24.04 as build
RUN apt-get update && apt-get install -y --no-install-recommends g++ make expat libexpat1-dev zlib1g-dev liblz4-dev bash wget
COPY build.sh ./build.sh
RUN ./build.sh

FROM ubuntu:24.04
RUN mkdir -p /opt/op/bin /opt/op/db 
COPY --from=build /overpass/bin /opt/op/bin/
RUN apt-get update && apt-get install -y --no-install-recommends osmium-tool bzip2
