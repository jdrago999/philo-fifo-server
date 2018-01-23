
FROM ruby

COPY . /opt/app

RUN \
  apt-get update \
  && apt-get install -y \
    sudo \
    build-essential \
    curl

RUN \
  useradd -d /home/ubuntu -m -s /bin/bash ubuntu \
  && echo "ubuntu:changeme" | chpasswd \
  && echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && sed -i s#/home/ubuntu:/bin/false#/home/ubuntu:/bin/bash# /etc/passwd


RUN \
  chown -R ubuntu:ubuntu /opt/app

WORKDIR /opt/app

USER ubuntu

RUN \
  bundle

ENTRYPOINT [".docker/docker-entrypoint.sh"]
