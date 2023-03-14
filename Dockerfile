FROM mysql/mysql-server:latest

ENV MYSQL_ROOT_PASSWORD=password123

EXPOSE 3307

CMD ["mysqld"]
