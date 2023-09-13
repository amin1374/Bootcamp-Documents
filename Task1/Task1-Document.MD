## Steps to install PostgreSQL 13 on Ubuntu 22.04 LTS
1. Update the package list and upgrade the existing packages:
```
sudo apt update && sudo apt upgrade
```
2. Import the PostgreSQL repository signing key:
```
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
```

3. Add the PostgreSQL repository to the package sources list:
```
echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" | sudo tee /etc/apt/sources.list.d/postgresql.list

```

4. Update the package list again:
```
sudo apt update
```
5. Install PostgreSQL 13:
```
sudo apt install postgresql-13
```

To set a password for the admin user in PostgreSQL and create a database and user, follow these steps:

1. Set a password for the `postgres` user:
```
sudo passwd postgres
```
Enter the new password when prompted.

2. Switch to the `postgres` user:
```
sudo su - postgres
```
3. Access the PostgreSQL command-line interface:
```
psql
```
4. Create a database named `mtr`:
```
CREATE DATABASE mtr;
```
5. Create a user named `amin` with an encrypted password:
```
CREATE USER amin WITH ENCRYPTED PASSWORD 'sina1384';
```
6. Grant all privileges on the `mtr` database to the `amin` user:
```
GRANT ALL PRIVILEGES ON DATABASE mtr TO amin;
```
7. Exit the PostgreSQL command-line interface:
```
\q
```
Now, you have set a password for the `postgres` user, created a database named `mtr`, and created a user named `amin` with the necessary privileges on the `mtr` database.
```
#!/bin/bash

# List of domains
domains=("google.com" "arvancloud.ir" "zoomit.ir" "kavenegar.com")

# Database connection details
db_host="127.0.0.1"
db_port="5432"
db_name="mtr"
db_user="amin"
db_password="sina1384"

# Create table if it doesn't exist
psql -h "$db_host" -p "$db_port" -d "$db_name" -U "$db_user" -c "
CREATE TABLE IF NOT EXISTS network (
    id SERIAL PRIMARY KEY,
    domain VARCHAR(255),
    jitter FLOAT,
    rtt FLOAT,
    loss FLOAT
);"

# Process each domain
for domain_name in "${domains[@]}"
do
    # Run the modified script and capture the output in a variable
    command=($(mtr -c 2 --csv -o MAL "$domain_name" | tail -1 | awk -F ',' '{print $4, $7, $8, $9, $3}'))

    # Insert the output into the database
  sudo PGPASSWORD="sina1384" psql -h "$db_host" -p "$db_port" -d "$db_name" -U "$db_user" -c "INSERT INTO network (domain, jitter, rtt, loss) VALUES ('${command[0]}', ${command[1]}, ${command[2]}, ${command[3]});" > /dev/null 2>&1
done
```
## Description of the script

In this script, several commands are used. These commands are as follows:

1. `psql`: This command is used to connect to a PostgreSQL database. Using parameters such as `-h` (host), `-p` (port), `-d` (database name), `-U` (username), and `-c` (SQL command), it connects to the database and executes the SQL command.

2. `mtr`: This command is used to measure and display network routing information. Using parameters like `-c` (number of packets sent), `--csv` (output format in CSV), `-o` (output type), and the domain name, it retrieves network information for the specified domain.

3. `tail`: This command is used to read the last lines of a file. Using the `-1` parameter, it reads and displays the last line.

4. `awk`: This command is used to process and extract data from a file or the output of other commands. Using the `-F` (delimiter) parameter and the domain name, it extracts the desired data.

5. `sudo`: This command is used to execute commands with superuser (admin) privileges.

6. `PGPASSWORD`: This environment variable is used to specify the password for the PostgreSQL database. By using this environment variable, the password can be automatically provided in the `psql` command.

7. `> /dev/null 2>&1`: This part of the code is used to redirect the output of `psql` commands to the `/dev/null` file. This action ensures that the output of the commands is discarded and not displayed.

Using these commands, the script can retrieve network information for each domain and store it in the database.

## Systemd Unitfile
To run a script under the control of systemd, you need to create a systemd service unit configuration file. 
```
sudo vi /etc/systemd/system/network-mtr.service
```
```
[Unit]
Description=Script Service
After=network.target

[Service]
ExecStart=/bin/bash /home/amin/Downloads/test/script.sh
WorkingDirectory=/home/amin/Downloads/test/
Restart=always
RestartSec=10
StandardOutput=null

[Install]
WantedBy=default.target
```
The following section of the unit file is for service settings. In this section, the settings for the script execution service are determined. Let's take a look at the explanation of each section:
[Unit]

`Description`: Provides a description of the service and its function. Here, the text "Script Service" is used as a description for the script service.

`After`: Specifies that the service should run after the "network.target" service. This means that the network service must be in the ready state before the script is executed.

[Service]

`ExecStart`: The command used to start the service. Here, the command /bin/bash /home/amin/Downloads/test/rc2-2.sh is specified to execute the script.

`WorkingDirectory`: The path in which the service runs. Here, the path /home/amin/Downloads/test/ is specified to run the service.

`Restart`: Specifies whether the service should be restarted in case of an error or unexpected stop. Here, the value always is used to specify that the service should always be restarted.

`RestartSec`: Specifies the delay between two service restarts. Here, the value 10 is used to specify a delay of 10 seconds between two restarts.

`StandardOutput`: Specifies where the service output should be directed. Here, the value null is used to specify that the service output should not be directed anywhere.

[Install]

`WantedBy`: Specifies at what stage of the system boot (boot process) the service should be enabled. Here, the value default.target is used to specify that the service should be enabled in the default stage of the system boot.

## To apply the changes to database access:

Edit the PostgreSQL configuration file. It is located in the path /etc/postgresql//main/pg_hba.conf. Open it with a text editor.
```
sudo nano /etc/postgresql/13/main/pg_hba.conf
```
Find the part of the file that looks like the following:

TYPE  DATABASE        USER            ADDRESS                 METHOD
Add the desired access to the lines below:
```
host    mtr         amin        192.168.100.1/32       md5
```

`mtr` is the name of the database to which you want to add access.

`amin` is the name of the user to which you want to add access.

`192.168.100.1/32` is the desired IP address.

`md5` is the type of authentication method. In this example, MD5 authentication is used. You can choose a different one based on your needs.

To apply the changes, you need to reload the PostgreSQL service.

```
sudo systemctl reload postgresql
```
or
```
su - postgres
/usr/bin/pg_ctl reload
```