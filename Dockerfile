FROM openfrontier/jenkins-swarm-maven-slave:oracle-jdk

MAINTAINER XJD <xing.jiudong@trans-cosmos.com.cn>

USER root

ENV ANT_VERSION=1.9.7 \
    IVY_VERSION=2.4.0 \
    ANT_CONTLIB_VERSION=1.0b3 \
    NODEJS_VERSION=v4.2.6 \
    JQ_VERSION=1.5

ENV REGISTRY_HOST=${REGISTRY_URL:-localhost}

# apache-ant
RUN mkdir /opt/ant \
    && wget -nv -P /opt/ant --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && wget -nv -P /opt/ant --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz.sha512 \
    && echo "$(cat /opt/ant/apache-ant-${ANT_VERSION}-bin.tar.gz.sha512) /opt/ant/apache-ant-${ANT_VERSION}-bin.tar.gz" | sha512sum -c \
    && tar -zxf /opt/ant/apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ant/ \
    && rm -f /opt/ant/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -f /opt/ant/apache-ant-${ANT_VERSION}-bin.tar.gz.sha512
ENV ANT_HOME /opt/ant/apache-ant-${ANT_VERSION}
ENV PATH ${PATH}:/opt/ant/apache-ant-${ANT_VERSION}/bin

# apache-ivy
RUN set -x && curl -fsSL http://archive.apache.org/dist/ant/ivy/${IVY_VERSION}/apache-ivy-${IVY_VERSION}-bin.tar.gz \
    | tar -xzC ${ANT_HOME}/lib && \
    cp ${ANT_HOME}/lib/apache-ivy-${IVY_VERSION}/ivy-${IVY_VERSION}.jar ${ANT_HOME}/lib/ && \
    rm -f ${ANT_HOME}/lib/apache-ivy-${IVY_VERSION}-bin.tar.gz && \
    rm -rf ${ANT_HOME}/lib/apache-ivy-${IVY_VERSION}/

# ant-contlib
RUN set -x && curl -fsSL https://jaist.dl.sourceforge.net/project/ant-contrib/ant-contrib/${ANT_CONTLIB_VERSION}/ant-contrib-${ANT_CONTLIB_VERSION}-bin.tar.gz \
    | tar -xzC ${ANT_HOME}/lib && \
    cp ${ANT_HOME}/lib/ant-contrib/ant-contrib-${ANT_CONTLIB_VERSION}.jar ${ANT_HOME}/lib/ && \
    rm -f ${ANT_HOME}/lib/ant-contrib-${ANT_CONTLIB_VERSION}-bin.tar.gz && \
    rm -rf ${ANT_HOME}/lib/ant-contrib/

# nodejs
RUN set -x && mkdir /opt/node && curl -fsSL https://nodejs.org/dist/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.gz \
    | tar -xzC /opt/node && \
    ln -s /opt/node/node-${NODEJS_VERSION}-linux-x64 /opt/node/default && \
    /opt/node/default/bin/npm config -g set registry  http://${REGISTRY_HOST}/nexus/content/groups/npm/

# jq
RUN set -x && curl -sLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 && \
    chmod +x /usr/local/bin/jq

USER "${JENKINS_USER}"
