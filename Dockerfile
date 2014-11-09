FROM ubuntu:14.10
MAINTAINER "Christian Kniep christian@qnib.org"

RUN apt-get -y update
RUN apt-get install -y wget curl

# install supervisor to supervise the processes within the container
RUN apt-get install -y supervisor
RUN sed -i -e "/^\[supervisord\]/a nodaemon = true" /etc/supervisor/supervisord.conf
RUN sed -i -e "/^\[unix_http_server\]/a username = user" /etc/supervisor/supervisord.conf
RUN sed -i -e "/^\[unix_http_server\]/a password = passwd" /etc/supervisor/supervisord.conf


## Install ES
# https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-on-an-ubuntu-vps
RUN apt-get install -y openjdk-8-jre
RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y elasticsearch=1.3.2
ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf

## Install MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN apt-get install -y mongodb-server=1:2.6.3-0ubuntu5
RUN mkdir -p /data/db
ADD etc/supervisor/conf.d/mongodb.conf /etc/supervisor/conf.d/

## Redis
RUN apt-get install -y redis-server=2:2.8.13-3
ADD etc/supervisor/conf.d/redis.conf /etc/supervisor/conf.d/

#### Locafox
WORKDIR /opt/
RUN wget --quiet http://de-locafox-engineering.s3.amazonaws.com/challenges/foxserver/foxserver_linux_amd64
RUN if [ "effbfb6741c6ef0d50341b2d0de33928" != $(md5sum /opt/foxserver_linux_amd64|awk '{print $1}') ]; then exit 1;fi
RUN chmod +x /opt/foxserver_linux_amd64
ADD etc/supervisor/conf.d/foxserver.conf /etc/supervisor/conf.d/
ADD root/bin/start_foxserver.sh /root/bin/start_foxserver.sh
ADD root/bin/check_foxserver.sh /root/bin/check_foxserver.sh
ADD etc/supervisor/conf.d/foxserver_complete.conf /etc/supervisor/conf.d/

CMD supervisord -c /etc/supervisor/supervisord.conf

