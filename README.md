# Split titanic.accdb into a MySQL backend and MS Access front end

## Introduction

This README provides instructions for splitting the `titanic.accdb` file into a MySQL backend and a Microsoft Access front end. The purpose of this process is to improve performance and reliability by moving the data to a more robust backend database system, while keeping the familiar front-end interface for users.

## Prerequisites
Before starting, you need to have the following prerequisites:

* Docker installed on the system where you want to run the MySQL server
* Microsoft Access installed on the system where you want to run the front end

##  Docker Setup
To set up the MySQL backend, we will use Docker. Follow the steps below:

1. Create a new Dockerfile with the following contents:

``` js
FROM mysql/mysql-server:latest

ENV MYSQL_ROOT_PASSWORD=password123

COPY my.cnf /etc/mysql/my.cnf

EXPOSE 3306

CMD ["mysqld"]
```

This Dockerfile sets the environment variable `MYSQL_ROOT_PASSWORD` to a password value, copies a custom configuration file `my.cnf` to the container's MySQL configuration directory, and exposes port 3306 to the Docker host.

2. Build the Docker image by running the following command in the same directory as the Dockerfile:

```bash
docker build -t titanicdb_img .
```

This command builds a Docker image from the Dockerfile and tags it with the name `titanicdb_img`.

3. Start a new Docker container from the titanicdb_img image by running the following command:

```css
docker run -p 3306:3306 --name titanicdb-container -d titanicdb_img
```

This command maps port 3306 on the Docker host to port 3306 inside the container, and runs the MySQL server process as the container's main command.

4. Find the IP address of the Docker host by running the following command:

```python
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' titanicdb-container
```

This command extracts the container's IP address from the container's network settings.

## MySQL Setup

Now that the MySQL server is running inside a Docker container, we need to create a new database and import the data from the titanic.accdb file. Follow the steps below:

1. Connect to the MySQL server running inside the Docker container by running the following command:

```css
mysql -h <docker-host-ip> -u root -p
```

Replace `<docker-host-ip>` with the IP address of the Docker host found in the previous step.

2. Create a new database by running the following command:

```sql
CREATE DATABASE titanicdb;
```

3. Import the data from the titanic.accdb file by running the following command:

```bash
mdb-schema titanic.accdb mysql | mysql -h <docker-host-ip> -u root -p titanicdb
mdb-tables -1 titanic.accdb | \
    grep -v '^MSys' | \
    xargs -I{} bash -c 'mdb-export titanic.accdb "{}" | mysql -h <docker-host-ip> -u root -p titanicdb'
```

The first line uses `mdb-schema` to generate the MySQL schema for the Microsoft Access database and pipes the output to the MySQL client to create the database schema.

The second line uses `mdb-tables` to list all the table names in the Microsoft Access database, filters out any system tables, and pipes the remaining table names to a loop that runs `mdb-export` to extract the data from each table and pipes it to the MySQL client to insert the data into the corresponding MySQL table.

Note that you will need to replace `<docker-host-ip>` with the IP address of your Docker host (see item 4).

## ODBC Driver Installation

```ps
# Define variables for the ODBC driver
$sqlServerDriverUrl = "https://dev.mysql.com/get/Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.32-winx64.msi"

# Define the paths for downloading and installing the driver
$downloadPath = "$env:USERPROFILE\Downloads"
$installPath = "C:\Drivers"

# Create the install path directory if it doesn't already exist
if (-not (Test-Path -Path $installPath -PathType Container)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
}

# Download and install the MySQL driver
$mysqlDriverFileName = "mysql-connector-odbc-8.0.32-winx64.msi"
$mysqlDriverDownloadUrl = "$mysqlDriverUrl/$mysqlDriverFileName"
$mysqlDriverDownloadPath = Join-Path $downloadPath $mysqlDriverFileName
$mysqlDriverInstallPath = Join-Path $installPath $mysqlDriverFileName

Invoke-WebRequest -Uri $mysqlDriverDownloadUrl -OutFile $mysqlDriverDownloadPath
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$mysqlDriverDownloadPath`" /qn /L*V `"$env:USERPROFILE\mysql.log`" INSTALLDIR=`"$mysqlDriverInstallPath`"" -Wait
```

This script downloads the MySQL Connector/ODBC driver from the specified URL, creates a directory for installing the driver, and installs the driver using the msiexec command. You can modify the $mysqlDriverUrl variable to point to a different version of the driver if needed.

Once the driver is installed, you must set up the ODBC data source for the MySQL database: 

```py
import os
import subprocess
import urllib.request

# Define variables for the ODBC driver
mysql_driver_version = "8.0.32"
mysql_driver_url = f"https://dev.mysql.com/get/Downloads/Connector-ODBC/{mysql_driver_version}/mysql-connector-odbc-{mysql_driver_version}-winx64.msi"

# Define the paths for downloading and installing the driver
download_path = os.path.join(os.path.expanduser("~"), "Downloads")
install_path = os.path.join("C:", "Drivers")

# Create the install path directory if it doesn't already exist
if not os.path.exists(install_path):
    os.makedirs(install_path)

# Download the MySQL driver
mysql_driver_file_name = os.path.basename(mysql_driver_url)
mysql_driver_download_path = os.path.join(download_path, mysql_driver_file_name)
urllib.request.urlretrieve(mysql_driver_url, mysql_driver_download_path)

# Install the MySQL driver silently
mysql_driver_install_path = os.path.join(install_path, mysql_driver_file_name)
subprocess.call(f'msiexec /i "{mysql_driver_download_path}" /qn /L*V "{os.path.expanduser("~")}\mysql.log" INSTALLDIR="{mysql_driver_install_path}"', shell=True)

# Set up the ODBC data source for the MySQL database
odbc_driver_name = "MySQL ODBC 8.0 Unicode Driver"
odbc_data_source_name = "my_mysql_db"
odbc_server_name = "localhost"
odbc_port_number = 3306
odbc_database_name = "my_database"
odbc_user_name = "my_username"
odbc_password = "my_password"

subprocess.call(f'odbcconf /a {{CONFIGDSN "MySQL ODBC 8.0 Unicode Driver" "DSN={odbc_data_source_name}|SERVER={odbc_server_name}|PORT={odbc_port_number}|DATABASE={odbc_database_name}|UID={odbc_user_name}|PWD={odbc_password}|OPTION=3"}}', shell=True)
```
