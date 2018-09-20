FROM openfrontier/jenkins-swarm-maven-slave:oracle-jdk

MAINTAINER XJD <xing.jiudong@trans-cosmos.com.cn>

USER root
# apache-ant
ENV ANT_VERSION 1.9.7
RUN mkdir /opt/ant && cd /opt/ant && wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz.sha512 \
    && echo "$(cat apache-ant-${ANT_VERSION}-bin.tar.gz.sha512) apache-ant-${ANT_VERSION}-bin.tar.gz" | sha512sum -c \
    && tar -zvxf apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ant/ \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz.sha512
ENV ANT_HOME /opt/ant/apache-ant-${ANT_VERSION}
ENV PATH ${PATH}:/opt/ant/apache-ant-${ANT_VERSION}/bin

# apache-ivy
WORKDIR /tmp
RUN set -x && curl -fsSL http://archive.apache.org/dist/ant/ivy/2.4.0/apache-ivy-2.4.0-bin.tar.gz \
    | tar -xzC /tmp && \
    cp /tmp/apache-ivy-2.4.0/ivy-2.4.0.jar ${ANT_HOME}/lib/ && \
    rm -f /tmp/apache-ivy-2.4.0-bin.tar.gz && \
    rm -rf /tmp/apache-ivy-2.4.0/

# ant-contlib
RUN set -x && curl -fsSL https://jaist.dl.sourceforge.net/project/ant-contrib/ant-contrib/1.0b3/ant-contrib-1.0b3-bin.tar.gz \
    | tar -xzC /tmp && \
    cp /tmp/ant-contrib/ant-contrib-1.0b3.jar ${ANT_HOME}/lib/ && \
    rm -f /tmp/ant-contrib-1.0b3-bin.tar.gz && \
    rm -rf /tmp/ant-contrib/

# nodejs
ENV REGISTRY_URL localhost
RUN mkdir /opt/node
RUN set -x && curl -fsSL https://nodejs.org/dist/v4.2.6/node-v4.2.6-linux-x64.tar.gz \
    | tar -xzC /opt/node && \
    chown -R root:root /opt/node/node-v4.2.6-linux-x64 && \
    chmod 775 /opt/node/node-v4.2.6-linux-x64 && \
    ln -s /opt/node/node-v4.2.6-linux-x64 /opt/node/default && \
    /opt/node/default/bin/npm config -g set registry  http://${REGISTRY_URL}/nexus/content/groups/npm/

# jq
RUN set -x && curl -sLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
    chmod +x /usr/local/bin/jq

WORKDIR /root

USER "${JENKINS_USER}"
