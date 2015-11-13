FROM java:8-jdk
MAINTAINER Andrew Grande

ADD ./nifi-0.4.0-SNAPSHOT-bin.tar .

VOLUME ["/output", "/flowconf", "/flowrepo",  "/contentrepo", "/databaserepo", "/provenancerepo"]

RUN sed -i 's/\.\/flowfile_repository/\/flowrepo/g' ./nifi-0.4.0-SNAPSHOT/conf/nifi.properties
RUN sed -i 's/\.\/content_repository/\/contentrepo/g' ./nifi-0.4.0-SNAPSHOT/conf/nifi.properties
RUN sed -i 's/\.\/conf\/flow\.xml\.gz/\/flowconf\/flow.xml.gz/' ./nifi-0.4.0-SNAPSHOT/conf/nifi.properties
RUN sed -i 's/\.\/conf\/archive/\/flowconf\/archive/' ./nifi-0.4.0-SNAPSHOT/conf/nifi.properties
RUN sed -i 's/\.\/database_repository/\/databaserepo/g' ./nifi-0.4.0-SNAPSHOT/conf/nifi.properties
RUN sed -i 's/\.\/provenance_repository/\/provenancerepo/g' ./nifi-0.4.0-SNAPSHOT/conf/nifi.properties


# web port
EXPOSE 8080

# listen port for web listening processor
EXPOSE 8081

WORKDIR nifi-0.4.0-SNAPSHOT
ENTRYPOINT ["bin/nifi.sh"]
CMD ["run"]
