# Script Tools Documentation

This folder contains scripts for automating database backups and other related tasks. Each script is documented separately below.

---

## automate_backups.sh

Automates the backup of a MySQL or PostgreSQL database running in a Docker container.

### Prerequisites
- Docker must be installed and running on your system.
- Bash shell environment (Linux or macOS recommended).

### Usage

```bash
./automate_backups.sh <engine> <host> <port> <user> <password> <database> <backup_dir>
```

#### Parameters
- `<engine>`: The database engine to use. Supported values: `mysql`, `postgres` (optionally with version, e.g., `mysql:8.0`, `postgres:15`).
- `<host>`: Hostname or IP address of the database (.
- `<user>`: Database username.
- `<password>`: Database password.
- `<database>`: Name of the database to back up.
- `<backup_dir>`: Directory where the backup file will be saved.

#### Example

```bash
./automate_backups.sh mysql:8.4 localhost  root mypassword mydatabase /home/user/backups
```

This will:
- Pull the MySQL Docker image if not present.
- Start a MySQL container.
- Create a backup of `mydatabase` and save it to `/home/user/backups/mydatabase_<date>.sql`.

#### Notes
- For PostgreSQL, use `postgres` as the engine and adjust the port/user/password/database accordingly.
- The script will print a usage message and exit if not all parameters are provided.
- Ensure the backup directory exists and is writable.

---

## [Other Scripts]

*Documentation for additional scripts will be added here as they are created.*

