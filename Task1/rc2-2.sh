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
