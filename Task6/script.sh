#!/bin/bash
# List of domains
domains=("google.com" "arvancloud.ir" "zoomit.ir" "kavenegar.com")

# Infinite loop to continuously execute the script
while true
do
    # Process each domain
    for domain_name in "${domains[@]}"
    do
        # Run the modified script and capture the output in a variable
        command=($(mtr -c 2 --csv -o MAL "$domain_name" | tail -1 | awk -F ',' '{print $4, $7, $8, $9, $3}'))

        # Create a JSON object from the command output
        json_data=$(echo "{ \"domain\": \"$domain_name\", \"rtt\": \"${command[2]}\", \"packet_loss\": \"${command[3]}\", \"jitter\": \"${command[1]}\", \"received\": \"${command[0]}\" }")

        # Save the JSON output to a file
        echo "$json_data" > output.json
        echo "$json_data"

    done

    # Sleep for 10 seconds before the next iteration
    sleep 10
done
