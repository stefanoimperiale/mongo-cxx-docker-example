FROM ubuntu:20.10 as build

ARG REPOSITORY_URL=https://github.com/stefanoimperiale/mongo-cxx-docker-example.git

RUN apt-get update && apt-get install -y build-essential git cmake wget \
 && mkdir build
WORKDIR build

RUN git clone ${REPOSITORY_URL} .
RUN ./build.sh

FROM ubuntu:20.10 as run
COPY build/testMongo /testMongo
CMD ['./testMongo']