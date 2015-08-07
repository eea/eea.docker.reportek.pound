FROM centos:centos7
MAINTAINER "Olimpiu Rob" <olimpiu.rob@eaudeweb.ro>

ENV EGGSHOP http://eggshop.eaudeweb.ro
ENV POUND_VERSION Pound-2.7
ENV POUND_CUSTOM _fix_cookie
ENV POUND_SRC $POUND_VERSION$POUND_CUSTOM.tgz
ENV POUND_URL_PATH $EGGSHOP/$POUND_SRC
ENV POUND_USER pound
ENV POUND_GROUP pound
ENV POUND_HOME /var/lib/pound

RUN yum install -y \
    openssl \
    openssl-devel \
    gcc

RUN mkdir -p $POUND_HOME/install && \
    groupadd -f -r $POUND_GROUP && \
    useradd -r -g $POUND_GROUP -d $POUND_HOME -s /sbin/nologin \
    -c "Pound user" $POUND_USER && \
    chown -R $POUND_USER:$POUND_GROUP $POUND_HOME

RUN mkdir -p /tmp/pound/install \
    && curl -SL $POUND_URL_PATH \
    | tar -xzC /tmp/pound/install \
    && cd /tmp/pound/install/$POUND_VERSION \
    && ./configure --with-owner=$POUND_USER --with-group=$POUND_GROUP \
    && make -C /tmp/pound/install/$POUND_VERSION \
    && make -C /tmp/pound/install/$POUND_VERSION install


ADD run.sh /bin/run.sh
RUN chmod a+x /bin/run.sh
COPY reload.sh  /bin/reload
RUN chmod a+x /bin/reload
RUN mkdir -p /etc/pound
CMD /bin/run.sh
