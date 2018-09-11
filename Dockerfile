# Use centos as the base layer or any GridServer supported OS platform.
FROM centos

USER root

# MAINTAINER is deprecated, use LABEL instead
LABEL maintainer="Tibco GridServer <support@tibco.com>"

# Product specific labels
LABEL io.k8s.display-name="TIBCO DataSynapse GridServer Engine"
LABEL tibco.gridserver.version="7.0.0"
LABEL summary="Provides GridServer Engine base image"

# The maximum heap size, in MB, as specified by the -Xmx<size> java option.
# Default is 1024m
ARG JVM_MAX_HEAP="1024m"

# Download the archive and extract it without writing the archive file to disk
RUN curl $GS_ARCHIVE_URL | tar xz -C /opt

# Manager communications (Engine File Server port)
EXPOSE 27159/tcp

RUN yum -y install bind-utils file hostname iproute iputils net-tools nmap traceroute && yum clean all -y

WORKDIR /opt/datasynapse/engine

RUN chmod -R a+w /opt/datasynapse/engine

CMD cd /opt/datasynapse/engine && ./configure.sh -s $DIRECTOR_URL && ./engine.sh start $ENGINE_CONFIG && tail -F /etc/hosts