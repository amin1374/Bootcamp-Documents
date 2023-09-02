#!/bin/bash

# List of domains
domains=("google.com" "arvancloud.ir" "zoomit.ir" "kavenegar.com")

# Database connection details
db_host=$DB_HOST
db_port=$DB_PORT
db_name=$DB_NAME
db_user=$DB_USER
db_password=$DB_PASSWORD

# Create table if it doesn't exist
psql -h "$db_host" -p "$db_port" -d "$db_name" -U "$db_user" -c "
CREATE TABLE IF NOT EXISTS network (
    id SERIAL PRIMARY KEY,
    domain VARCHAR(255),
    jitter FLOAT,
    rtt FLOAT,
    loss FLOAT
);"

# Infinite loop to continuously execute the script
while true
do
    # Process each domain
    for domain_name in "${domains[@]}"
    do
        # Run the modified script and capture the output in a variable
        command=($(mtr -c 2 --csv -o MAL "$domain_name" | tail -1 | awk -F ',' '{print $4, $7, $8, $9, $3}'))

        # Insert the output into the database
        PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -d "$db_name" -U "$db_user" -c "INSERT INTO network (domain, jitter, rtt, loss) VALUES ('${command[0]}', ${command[1]}, ${command[2]}, ${command[3]});" > /dev/null 2>&1
    done

    # Sleep for 10 seconds before the next iteration
    sleep 10
done
