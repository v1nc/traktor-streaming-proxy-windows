FROM ubuntu:jammy

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y openjdk-18-jre-headless

COPY . /app
WORKDIR /app

# uncomment the following to build yourself
# RUN chmod +x ./gradlew
# RUN ./gradlew distTar --no-daemon

FROM ubuntu:jammy

RUN apt-get update && apt upgrade -y
RUN apt-get install -y openjdk-18-jre-headless nginx patch ffmpeg

WORKDIR /app

COPY --from=0 /app/nginx-default.patch /app
RUN patch -d / -p0 < nginx-default.patch && rm nginx-default.patch

COPY --from=0 /app/build/distributions/traktor-streaming-proxy.tar /app
RUN tar xf traktor-streaming-proxy.tar --strip-components=1 && rm traktor-streaming-proxy.tar

COPY server.crt /app/cert/server.crt
COPY server.key /app/cert/server.key
COPY config.properties /app/config.properties
COPY license /app/license

CMD nginx && bin/traktor-streaming-proxy
