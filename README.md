docker-foxserver
================

Container serving foxserver

My idea of how a webapp should be servered..

## Build

To build the container checkout the repository and run
```bash
$ docker build --rm -t qnib/foxserver .
```

## Run

```bash
# docker run -ti --rm -p 127.0.0.1:3000:3000 qnib/foxserver
2014-11-09 15:27:03,793 CRIT Supervisor running as root (no user in config file)
2014-11-09 15:27:03,794 WARN Included extra file "/etc/supervisor/conf.d/foxserver.conf" during parsing
2014-11-09 15:27:03,794 WARN Included extra file "/etc/supervisor/conf.d/redis.conf" during parsing
2014-11-09 15:27:03,795 WARN Included extra file "/etc/supervisor/conf.d/mongodb.conf" during parsing
2014-11-09 15:27:03,795 WARN Included extra file "/etc/supervisor/conf.d/elasticsearch.conf" during parsing
2014-11-09 15:27:03,811 INFO RPC interface 'supervisor' initialized
2014-11-09 15:27:03,811 CRIT Server 'unix_http_server' running without any HTTP authentication checking
2014-11-09 15:27:03,811 INFO supervisord started with pid 9
2014-11-09 15:27:04,821 INFO spawned: 'mongodb' with pid 12
2014-11-09 15:27:04,829 INFO spawned: 'redis' with pid 13
2014-11-09 15:27:04,848 INFO spawned: 'elasticsearch' with pid 14
2014-11-09 15:27:04,873 INFO spawned: 'foxserver' with pid 17
2014-11-09 15:27:06,293 INFO success: mongodb entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2014-11-09 15:27:06,293 INFO success: redis entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2014-11-09 15:27:06,294 INFO success: elasticsearch entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2014-11-09 15:27:19,866 INFO success: foxserver entered RUNNING state, process has stayed up for > than 15 seconds (startsecs)
```

## Check

If everything went OK, the server should reply with the status OK.

```bash
# curl http://localhost:3000
{"status":"OK","token":"pfyrAVKXKcfQM7j41BDWfDK1qbl03rUivgTv0YwW"}
```


# Security

Since the complete stack is running within a container, the endpoints for MongoDB, Redis and ES are not exposed to the outside world.

From the server itself the container could be reached:

```bash
# docker inspect -f '{{ .NetworkSettings.IPAddress }}' loving_yonath
172.17.0.80
# curl http://172.17.0.80:9200
{
  "status" : 200,
  "name" : "Miles Warren",
  "version" : {
    "number" : "1.3.2",
    "build_hash" : "dee175dbe2f254f3f26992f5d7591939aaefd12f",
    "build_timestamp" : "2014-08-13T14:29:30Z",
    "build_snapshot" : false,
    "lucene_version" : "4.9"
  },
  "tagline" : "You Know, for Search"
}
#
```

If this is a problem ES and Redis could be configured to accept only localhost connection. 

