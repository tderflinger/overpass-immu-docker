FROM alpine AS build
RUN apk add g++ make expat expat-dev zlib-dev lz4-dev bash
COPY build.sh ./build.sh
RUN ./build.sh

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends osmium-tool bzip2

RUN mkdir -p /opt/op/db

COPY --from=build /overpass/bin /opt/op/
#COPY ./binaries/** /opt/op


