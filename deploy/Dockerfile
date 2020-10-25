FROM rikorose/gcc-cmake as build

ARG REPOSITORY_URL=https://github.com/stefanoimperiale/mongo-cxx-docker-example.git
ARG CONNECTION_URL

RUN mkdir build
WORKDIR build
RUN git clone ${REPOSITORY_URL} .
RUN ./install-mongo-lib.sh
RUN if [ -z "${CONNECTION_URL}" ]; then ./build.sh else ./build.sh -u "${CONNECTION_URL}"; fi
ENTRYPOINT ["/build/build/testMongo"]