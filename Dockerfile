FROM mysql/mysql-server:latest

ENV MYSQL_ROOT_PASSWORD=password123

EXPOSE 3306

CMD ["mysqld", "--port=3306"]
