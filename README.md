docker-foxserver
================

My idea of how a webapp should be servered..

## But why?

### speed

- `deployment speed` Spawning a docker container is way faster then spawning a virtual machine (whereever this machine is hosted).
- `node speed` as shown in [my studies](http://qnib.org/qnibterminal/2014/11/06/Containerized-MPI-workloads/) within the HPC field a docker container introduces very little overhead and is not dependend of the bare-metals userland performance. If the containers userland is faster then the bare-metal one, the container is able to beat the performance.


### continous deployment
As in the given scenario the EC2 instance would be up and running and within this instance the container could be changed 
if a new version of foxserver is deployed.

### split of concern

Within this monolithic Image all services are provided. In a later version this would be split up in multiple containers. In fact at least one per
service. By linking ```--link``` the containers it is easy to spin up the infrastructure.


## Build

To build the container checkout the repository and run

```bash
$ docker build --rm -t qnib/foxserver .
```

## Run

The container is started as shown above. This will expose the port 3000 only for the docker host itself.

```bash
$ docker run -ti --rm -p 127.0.0.1:3000:3000 qnib/foxserver
2014-11-09 16:12:46,300 CRIT Supervisor running as root (no user in config file)
2014-11-09 16:12:46,301 WARN Included extra file "/etc/supervisor/conf.d/foxserver_complete.conf" during parsing
2014-11-09 16:12:46,301 WARN Included extra file "/etc/supervisor/conf.d/foxserver.conf" during parsing
2014-11-09 16:12:46,301 WARN Included extra file "/etc/supervisor/conf.d/redis.conf" during parsing
2014-11-09 16:12:46,302 WARN Included extra file "/etc/supervisor/conf.d/mongodb.conf" during parsing
2014-11-09 16:12:46,302 WARN Included extra file "/etc/supervisor/conf.d/elasticsearch.conf" during parsing
2014-11-09 16:12:46,318 INFO RPC interface 'supervisor' initialized
2014-11-09 16:12:46,319 INFO supervisord started with pid 8
2014-11-09 16:12:47,325 INFO spawned: 'mongodb' with pid 11
2014-11-09 16:12:47,338 INFO spawned: 'redis' with pid 12
2014-11-09 16:12:47,348 INFO spawned: 'elasticsearch' with pid 13
2014-11-09 16:12:47,374 INFO spawned: 'foxserver_complete' with pid 17
2014-11-09 16:12:47,391 INFO spawned: 'foxserver' with pid 20
2014-11-09 16:12:48,849 INFO success: mongodb entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2014-11-09 16:12:48,849 INFO success: redis entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2014-11-09 16:12:48,850 INFO success: elasticsearch entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2014-11-09 16:12:48,850 INFO success: foxserver_complete entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2014-11-09 16:12:57,634 INFO exited: foxserver_complete (exit status 0; expected)
2014-11-09 16:13:02,641 INFO success: foxserver entered RUNNING state, process has stayed up for > than 15 seconds (startsecs)
```

There are five supervisord processes.

- mongodb serves a mongodb server
- redis serves a redis server
- elasticsearch servers an elasticsearch server
- foxserver starts a script that provides the BACKEND environment variables and starts the foxserver_linux64 
- foxserver_complete checks for the foxserver to come up and if so, sends /complete

# Security

## Docker in general

Docker is still in beta phase and the security is not as sorted out yet. 
Compared to traditional virtualisation the container might suffer a bigger attack vector, since an kernel exploit would effect the hosts kernel, whereas
in traditional virtualization the attacker has to penetrate the hypervisor as well.

### SELinux

To get the security tight one has to use SELinux in the docker context. Docker supports the use.
However, I have not looked into SELinux, since my working environments weren't as security constraint. They were never exposed to 
'the internet' and therefore SElinux is disabled by default.

### socket

If someone is allowed to write to the docker socket he is able to mess with the docker container, spawn new once and thus alter the hosts file system.

```bash
ls -l /var/run/docker.sock
srw-rw---- 1 root docker 0 Nov  9 13:30 /var/run/docker.sock
```

## Container
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

