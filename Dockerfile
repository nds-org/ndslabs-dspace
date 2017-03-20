#
# DSpace image
#

FROM maven:3.3.9-jdk-7

# Build Arguments
ARG TOMCAT_VERSION="8.0.42"
ARG DSPACE_VERSION="5.4"

# Environment variables
ENV CATALINA_HOME=/usr/local/tomcat DSPACE_HOME=/dspace
ENV PATH=$CATALINA_HOME/bin:$DSPACE_HOME/bin:$PATH

WORKDIR /tmp

# Install runtime and dependencies
RUN apt-get update && apt-get install -y vim ant nmap postgresql-client \
    && apt-get -qq autoremove \
    && apt-get -qq autoclean \
    && apt-get -qq clean all \
    && rm -rf /var/cache/apk/* /tmp/* /var/lib/apt/lists/*

RUN mkdir -p dspace "$CATALINA_HOME" \
    && curl -fSL http://apache.mirrors.tds.net/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -o tomcat.tar.gz \
    && curl -L https://github.com/DSpace/DSpace/releases/download/dspace-${DSPACE_VERSION}/dspace-${DSPACE_VERSION}-release.tar.gz -o dspace.tar.gz \
    && tar -xvf tomcat.tar.gz --strip-components=1 -C "$CATALINA_HOME" \
    && tar -xvf dspace.tar.gz --strip-components=1  -C dspace \
    && cd dspace && mvn package \
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
