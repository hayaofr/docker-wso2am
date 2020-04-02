FROM openjdk:8-jre-alpine

ARG WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION:-2.1.0}
ARG PRODUCT_ID=${PRODUCT_ID:-api-manager}
ARG WSO2_SERVER=${WSO2_SERVER:-wso2am}
ARG PRODUCT_USER=${PRODUCT_USER:-wso2user}
ARG PRODUCT_REPOSITORY=${PRODUCT_REPOSITORY:-'https://product-dist.wso2.com/products'}

RUN addgroup -S ${PRODUCT_USER} && adduser -S -g ${PRODUCT_USER} ${PRODUCT_USER}

RUN apk add --no-cache --update-cache \
	  ca-certificates \
	  unzip \
      wget \
	  && \
    wget \
	  --progress=dot:giga \
	  --referer="http://connect.wso2.com/wso2/getform/reg/new_product_download" \
	  -O "/tmp/${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip" \
	  "${PRODUCT_REPOSITORY}/${PRODUCT_ID}/${WSO2_SERVER_VERSION}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip" && \
    unzip /tmp/${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip -d /opt && \
	chmod o-rwx -R /opt/${WSO2_SERVER}-${WSO2_SERVER_VERSION} && \
	chown ${PRODUCT_USER}:${PRODUCT_USER} -R /opt/${WSO2_SERVER}-${WSO2_SERVER_VERSION} && \
    rm /tmp/${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip && \
    apk del \
	  ca-certificates \
	  unzip \
      wget

RUN sed -i -e 's/<!--HostName>www.wso2.org<\/HostName-->/<HostName>localhost<\/HostName>/g' /opt/wso2am-${WSO2_SERVER_VERSION}/repository/conf/carbon.xml &&\
sed -i -e 's/\${carbon.local.ip}/localhost/g' /opt/wso2am-${WSO2_SERVER_VERSION}/repository/conf/api-manager.xml

ENV JAVA_OPTS "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=12345"

EXPOSE 9443 9763 8243 8280 10397 7711 9711 9611 5672 8672 12345
WORKDIR /opt/${WSO2_SERVER}-${WSO2_SERVER_VERSION}
ENTRYPOINT ["bin/wso2server.sh"]
