FROM larcnhan/base:0.3
MAINTAINER LarcnHan <larcnhan@126.com>

WORKDIR /app
VOLUME /app
COPY startup.sh /startup.sh

RUN apk add --update mysql mysql-client && rm -f /var/cache/apk/*
RUN mkdir -p /install
COPY my.cnf /etc/mysql/my.cnf
COPY my.cnf /install/my.cnf

EXPOSE 3306
CMD ["/startup.sh"]
