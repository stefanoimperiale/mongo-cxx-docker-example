FROM rikorose/gcc-cmake as build

ARG REPOSITORY_URL=https://github.com/stefanoimperiale/mongo-cxx-docker-example.git

RUN mkdir build
WORKDIR build
RUN git clone ${REPOSITORY_URL} .
RUN ./install-mongo-lib.sh
RUN ./build.sh
CMD ['/build/build/testMongo']