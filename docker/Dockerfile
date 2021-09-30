FROM ubuntu:21.04

RUN apt update && apt install -y maven \
      git \
      htop \
      nano \
      iputils-ping \
      wget \
      net-tools

COPY reactive-mode-demo-jobs /project
COPY ./docker/docker-entrypoint.sh /

RUN ["chmod", "+x", "/docker-entrypoint.sh"]

WORKDIR /project

RUN mvn clean install

ENTRYPOINT ["/docker-entrypoint.sh"]
