#!/bin/bash
# Description: This script automates the backup of a MySQL or PostgreSQL database from a Docker container.
#󰛓 ❯ docker cp mysql8.0:/tmp/qa-services /home/erick/Documents/qa-services

engine=$1
host=$2
user=$3
password=$4
database=$5
backup_dir=$6

today=$(date +%F)

local_password=OcelOps
local_user=ocelotl
# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not properly installed"
  exit 1
fi

# Check if all arguments are provided
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <engine> <host> <port> <user> <password> <database> <backup_dir>"
    echos "Missing arguments. Please provide all required parameters."
    echo "Example: $0 mysql:8.0 localhost 3306 root mypassword mydatabase /path/to/backup"
    exit 1
fi

echo "Pulling Docker image for $engine..."
docker pull $engine

# Check if Docker image exists locally
if [ -z "$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -w "$engine")" ]; then
    echo "Docker image $engine not found locally. Try again."
    exit 1
fi

container_name=$(echo "$engine" | sed 's/[:.]/-/g')

if  [[ "$engine" == "mysql"* ]]; then
  echo "Running MySQL container..."
  docker run --name $container_name -p 3306:3306 -e MYSQL_ROOT_PASSWORD=$local_password -e MYSQL_DATABASE=mydatabase -e MYSQL_USER=$local_user -e MYSQL_PASSWORD=$local_password -v /data/mysql:/var/lib/mysql -d $engine

  if [ "$(docker ps -q -f name=$container_name)" ]; then
    echo "Container $container_name is running."
  else
    echo "Failed to start container $container_name."
    exit 1
  fi

  echo "Backing up MySQL database..."
  docker exec $container_name mysqldump -h $host -P 3306 -u $user -p$password $database > "$backup_dir/${database}_${today}.sql"
fi

if [[ "$engine" == "postgres"* ]]; then
  echo "Running PostgreSQL container..."
  docker run --name $container_name -p 5432:5432 -e POSTGRES_PASSWORD=$password -e POSTGRES_USER=$user -e POSTGRES_DB=$database -v /data/postgres:/var/lib/postgresql/data -d $engine
  if [ "$(docker ps -q -f name=$container_name)" ]; then
    echo "Container $container_name is running."
  else
    echo "Failed to start container $container_name."
    exit 1
  fi

  echo "Backing up PostgresSQL database..."
  docker exec -e PGPASSWORD=$password $container_name pg_dump -h $host -p 5432 -U $user $database > "$backup_dir/${database}_${today}.sql"



fi

if test -f "$backup_dir/${database}_${today}.sql"; then
    echo "Backup completed successfully."
else
    echo "Something went wrong "
fi


docker stop $container_name
echo "Container stopped"
docker rm $container_name
echo "Container killed"
if [[ "$engine" == "mysql"* ]]; then
  rm -rf /data/mysql
  echo "Old MySQL data directory removed."
else
  rm -rf /data/postgres
  echo "Old PostgreSQL data directory removed."
fi

echo "Old PostgreSQL data directory removed."
