
# Introduction 

Special thanks for Github user [trkurc](https://github.com/trkurc) for providing the 0.1.0 version

Dockerfile to build a nifi container image

## Version

Apache NiFi 0.2.1

# Quick Start

### Warning 

This will open listening ports - ensure that your host OS has protections in place such that the port is only open to machines you know about, e.g. with a firewall like iptables (I recommend that you configure your firewall to only allow localhost access to ports 8080 and 8081 for test purposes))

You can launch the image using the docker command line

```bash
docker run -d --name=nifi_021 \
-p 8080:8080 -p 8081:8081 \
-v /tmp/output:/output \
jdye64/nifi_021
```

You can view the startup progress using docker logs command

```bash
docker logs -f nifi_021
```

The application is started when you see a line similar to the one below:

```
2015-09-01 20:22:50,217 INFO [NiFi logging handler] org.apache.nifi.StdOut 2015-09-01 20:22:50,217 INFO [main] org.apache.nifi.web.server.JettyServer NiFi has started. The UI is available at the following URLs:
```

Point your browser to `http://localhost:8080/nifi` or if your using local docker-machine instance 'http://{docker-machine IP}:8080/nifi'

You can find the docker-machine ip address by running docker-machine ls.

The port 8081 is exposed, not for the application but for sampling the use of processors that will listen on ports (such as ListenHTTP). 
Likewise the `-v /tmp/output:/output' mounts the /tmp/output directory in the host to the data volume /output in the container, to 
sample the use of processors which can write to the local filesystem (PutFile). 

### Problems

If you see a message like this 
```
Get http:///var/run/docker.sock/v1.20/containers/json: dial unix /var/run/docker.sock: no such file or directory.
* Are you trying to connect to a TLS-enabled daemon without TLS?
* Is your docker daemon up and running?
```

while trying to run any docker commands on your Mac OS X machine try running 

```
eval "$(docker-machine env {DOCKER-MACHINE-NAME})"
```

Where DOCKER-MACHINE-NAME is the name of a docker-machine that you have previously created. The default docker-machine is "default"
