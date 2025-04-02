# Stolen from https://github.com/lindycoder/prepopulated-mysql-container-example
FROM harbor.maxiv.lu.se/dockerhub/library/mariadb:10.11.11 as builder

RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

#ENV MYSQL_ROOT_PASSWORD=rootpassword
#ENV MYSQL_PASSWORD=test
#ENV MYSQL_USER=test 
#ENV MYSQL_DATABASE=mysql
ENV MARIADB_ROOT_PASSWORD=rootpassword
ENV MARIADB_DATABASE=mysql

COPY ./schema /tmp/schema/
COPY ./scripts /tmp/scripts/
COPY ./grants /tmp/grants/

#COPY ./scripts/.my.cnf /etc/mysql/conf.d/my.cnf

RUN apt-get update && apt-get install -y wget vim && \
    cp /tmp/scripts/build_docker.sh /docker-entrypoint-initdb.d/6_build.sh && \
    /usr/local/bin/docker-entrypoint.sh mysqld --datadir /initialized-db --aria-log-dir-path /initialized-db && \
    rm /docker-entrypoint-initdb.d/6_build.sh && \
    apt-get clean autoclean && apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/*

FROM harbor.maxiv.lu.se/dockerhub/library/mariadb:10.11.11
COPY --from=builder /initialized-db /var/lib/mysql



