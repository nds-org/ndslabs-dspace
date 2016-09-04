#
# DSpace image
#

FROM java:openjdk-7u95

# Environment variables
ENV CATALINA_HOME=/usr/local/tomcat DSPACE_HOME=/dspace
ENV PATH=$CATALINA_HOME/bin:$DSPACE_HOME/bin:$PATH

WORKDIR /tmp

# Install runtime and dependencies
RUN apt-get update && apt-get install -y vim ant nmap postgresql-client \
    && mkdir -p maven dspace "$CATALINA_HOME" \
    && curl -fSL http://apache.mirrors.tds.net/tomcat/tomcat-8/v8.0.36/bin/apache-tomcat-8.0.36.tar.gz -o tomcat.tar.gz \
    && curl -fSL http://apache.mirror.iweb.ca/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz -o maven.tar.gz \
    && curl -L https://github.com/DSpace/DSpace/releases/download/dspace-5.4/dspace-5.4-release.tar.gz -o dspace.tar.gz \
    && tar -xvf tomcat.tar.gz --strip-components=1 -C "$CATALINA_HOME" \
    && tar -xvf maven.tar.gz --strip-components=1  -C maven \
    && tar -xvf dspace.tar.gz --strip-components=1  -C dspace \
    && cd dspace && ../maven/bin/mvn package \
    && cd dspace/target/dspace-installer \
    && ant init_installation init_configs install_code copy_webapps \
    && rm -fr "$CATALINA_HOME/webapps" && mv -f /dspace/webapps "$CATALINA_HOME" \
    && mv $CATALINA_HOME/webapps/xmlui $CATALINA_HOME/webapps/ROOT \
    && sed -i s/CONFIDENTIAL/NONE/ /usr/local/tomcat/webapps/rest/WEB-INF/web.xml \
    && rm -fr ~/.m2 && rm -fr /tmp/* && apt-get remove -y ant

# Install root filesystem
ADD entrypoint.sh /

WORKDIR /dspace

EXPOSE 8080
CMD ["/entrypoint.sh"]
