#!/bin/bash
# Description: This script automates the backup of a MySQL or PostgreSQL database from a Docker container.
#󰛓 ❯ docker cp mysql8.0:/tmp/qa-services /home/erick/Documents/qa-services

engine=$1
host=$2
port=$3
user=$4
password=$5
database=$6
backup_dir=$7

today=$(date +%F)

local_password=OcelOps
local_user=ocelotl
# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not properly installed"
  exit 1
fi

# Check if all arguments are provided
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <engine> <host> <port> <user> <password> <database> <backup_dir>"
    exit 1
fi

docker pull $engine

if [ docker images --filter=reference="$engine" | wc -l -eq 1 ]; then
    echo "Docker image $engine not found. Try agaian "
    exit 1
fi

# Normalize Docker container name (replace : and . with -)
container_name=$(echo "$engine" | sed 's/[:.]/-/g')

if  [[ "$engine" == "mysql"* ]]; then
  docker run --name $container_name -p 3306:3306 -e MYSQL_ROOT_PASSWORD=securepassword -e MYSQL_DATABASE=mydatabase -e MYSQL_USER=$local_user -e MYSQL_PASSWORD=$local_password -v /data/mysql:/var/lib/mysql -d $engine
  docker exec $container_name /usr/bin/mysqldump -h $host -P $port -u $user --password=$password $database > $backup_dir/"$database_$today".sql
fi

if [[ "$engine" == "postgres"* ]]; then
  docker run --name $container_name -p 5432:5432 -e POSTGRES_PASSWORD=$password -e POSTGRES_USER=$user -e POSTGRES_DB=$database -v /data/postgres:/var/lib/postgresql/data -d $engine
  docker exec $container_name pg_dump -h $host -p $port -U $user $database > $backup_dir/"$database_$today".sql
fi
