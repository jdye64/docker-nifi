FROM java:8-jdk
MAINTAINER Andrew Grande

ADD ./nifi-0.4.0-SNAPSHOT-bin.tar.gz .

VOLUME ["/output", "/flowconf", "/flowrepo",  "/contentrepo", "/databaserepo", "/provenancerepo"]

ENV NIFI_HOME=/nifi-0.4.0-SNAPSHOT

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# web port
EXPOSE 8080

# listen port for web listening processor
EXPOSE 8081

WORKDIR nifi-0.4.0-SNAPSHOT/bin
ADD ./run.sh .
RUN chmod +x ./run.sh
ENTRYPOINT ["./run.sh"]
