FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends osmium-tool bzip2

RUN mkdir -p /opt/op/db

COPY ./binaries/** /opt/op


