# Use centos as the base layer
FROM centos

# Docker has deprecated MAINTAINER but if not set, the Author field will not be set in the OpenShift Console
MAINTAINER Ed Gutarra <egutarra@tibco.com>

LABEL name="TIBCO DataSynapse GridServer Engine" \
      maintainer="Ed Gutarra <egutarra@tibco.com>" \
      summary="Provides TIBCO DataSynapse GridServer Engine base image" \
      description="TIBCO DataSynapse GridServer Engine base image built on Deutsche Bank approved Java 8 image." \
      version="6.2.0" \
      db.gridserver.version="6.2.0"

ARG MANAGER_HOST=lin64vm505.rofa.tibco.com
ARG MANAGER_PORT=8080

# Obtain the vendor-provided archive from Artifactory
ARG GS_ARCHIVE_URL=http://${MANAGER_HOST}:${MANAGER_PORT}/livecluster/public_html/register/install/unixengine/DSEngineLinux64.tar.gz

# The maximum heap size, in MB, as specified by the -Xmx<size> java option.
# Default is 1024m
ARG JVM_MAX_HEAP="1024m"

# Download the archive and extract it without writing the archive file to disk
RUN curl $GS_ARCHIVE_URL | tar xz -C /opt

# Fix permissions issues caused by Docker building as root but running as random user IDs
# RUN chmod +x *.sh && chmod -R a+w .

# Manager communications (between directors and brokers)
EXPOSE 27159/tcp

# Install tools to help debug Avi issues and other utils required by configure.sh
RUN yum -y install bind-utils file hostname iproute iputils net-tools nmap traceroute && yum clean all -y
WORKDIR /opt/datasynapse/engine
RUN chmod -R a+w /opt/datasynapse/engine
CMD cd /opt/datasynapse/engine && ./configure.sh -s ${MANAGER_HOST}:${MANAGER_PORT} && ./engine.sh start && sleep infinity

