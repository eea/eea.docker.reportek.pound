FROM centos:centos7
MAINTAINER "Olimpiu Rob" <olimpiu.rob@eaudeweb.ro>

ENV EGGSHOP http://eggshop.eaudeweb.ro
ENV POUND_VERSION Pound-2.7
ENV POUND_CUSTOM _fix_cookie
ENV POUND_SRC $POUND_VERSION$POUND_CUSTOM.tgz
ENV POUND_PATH $EGGSHOP/$POUND_SRC

RUN yum install -y \
    openssl \
    openssl-devel \
    gcc

RUN mkdir -p /tmp/pound \
    && curl -SL $POUND_PATH \
    | tar -xzC /tmp/pound \
    && cd /tmp/pound/$POUND_VERSION \
    && ./configure \
    && make -C /tmp/pound/$POUND_VERSION \
    && make -C /tmp/pound/$POUND_VERSION install
