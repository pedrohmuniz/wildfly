FROM jboss/base-jdk:11
MAINTAINER  Pedro Muniz  pedrohfm@algartech.com

ENV WILDFLY_VERSION 15.0.1.Final
ENV WILDFLY_SHA1 23d6a5889b76702fc518600fc5b2d80d6b3b7bb1
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

COPY ["postgresql-9.4.1209.jre7.jar", "ojdbc8.jar", "cli-offline.sh", "$JBOSS_HOME/bin/"]
RUN $JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/bin/cli-offline.sh

RUN cd $JBOSS_HOME \
rm -f \
bin/cli-offline.sh \
bin/postgresql-9.4.1209.jre7.jar \
bin/ojdbc8.jar

RUN mkdir -p \
/var/log/wildfly \
/var/run/wildfly

RUN chown jboss: -R \
$JBOSS_HOME \
/var/log/wildfly \
/var/run/wildfly

RUN rm -rf /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/current/*

ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

EXPOSE 8080 9990

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "-Djboss.bind.address.unsecure=0.0.0.0", "-Djboss.domain.base.dir=/opt/jboss/wildfly/standalone", "-Djboss.server.log.dir=/var/log/wildfly"]
