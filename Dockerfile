FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y mysql-server

RUN mkdir /app

EXPOSE 3306

CMD ["mysqld", "--port=3306", "--datadir=/app", "--user=mysql"]
