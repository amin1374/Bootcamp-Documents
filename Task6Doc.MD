
## Prometheus Bash Script Exporter 

This script uses the mtr command to monitor the latency, packet loss, jitter, and received packets of a list of domains. The script runs in an infinite loop, continuously monitoring the domains. The output of the script is a JSON object that is saved to a file called output.json.
```
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
```
To extract the data stored by the script and receive it in Prometheus format, we need to write the following Python script.

```
import json
import time
from prometheus_client import start_http_server, Gauge, Info

# Create Prometheus metrics
rtt_metric = Gauge('domain_rtt', 'Round-trip time for the domain', ['domain'])
packet_loss_metric = Gauge('domain_packet_loss', 'Packet loss for the domain', ['domain'])
jitter_metric = Gauge('domain_jitter', 'Jitter for the domain', ['domain'])
received_metric = Info('domain_received', 'Received value for the domain')

# Parse the JSON data and update the metrics
def update_metrics(json_data):
    if isinstance(json_data, str):
        json_data = json.loads(json_data)
    domain = json_data['domain']
    rtt = float(json_data['rtt'])
    packet_loss = float(json_data['packet_loss'])
    jitter = float(json_data['jitter'])
    received = json_data['received']

    rtt_metric.labels(domain).set(rtt)
    packet_loss_metric.labels(domain).set(packet_loss)
    jitter_metric.labels(domain).set(jitter)
    received_metric.info({'domain': domain, 'received': received})

# Start the Prometheus HTTP server
start_http_server(7000)

# Read and update the metrics every 10 seconds
while True:
    with open('output.json') as file:
        json_data = json.load(file)
    if isinstance(json_data, list):
        for data in json_data:
            update_metrics(data)
    else:
        update_metrics(json_data)
    time.sleep(10)
```
This script is used to update Prometheus metrics based on JSON data.
1. Import the required libraries: `json` for parsing JSON data, `time` for time-related operations, and `prometheus_client` for creating Prometheus metrics.

2. Create Prometheus metrics:
   - `rtt_metric` is a gauge metric that represents the round-trip time for a domain.
   - `packet_loss_metric` is a gauge metric that represents the packet loss for a domain.
   - `jitter_metric` is a gauge metric that represents the jitter for a domain.
   - `received_metric` is an info metric that represents the received value for a domain.

3. Define the `update_metrics` function:
   - This function takes JSON data as input and updates the metrics accordingly.
   - If the input is a string, it is converted to a JSON object using `json.loads`.
   - The `domain`, `rtt`, `packet_loss`, `jitter`, and `received` values are extracted from the JSON data.
   - The metrics are updated using the `set` and `info` methods of the respective metrics.

4. Start the Prometheus HTTP server on port 7000 using `start_http_server`.

5. Read and update the metrics every 10 seconds:
   - The script opens the `output.json` file.
   - If the JSON data is a list, the `update_metrics` function is called for each item in the list.
   - If the JSON data is not a list, the `update_metrics` function is called once.
   - After updating the metrics, the script sleeps for 10 seconds using `time.sleep`.

To run the script in the Kubernetes cluster, we need it to create its Dockerfile.

```
# Use a base image with the necessary dependencies
FROM ubuntu:latest

# Install required packages
RUN apt-get update && apt-get install -y mtr

# Install Python and necessary packages
RUN apt-get install -y python3 python3-pip
RUN pip3 install prometheus_client


# Copy the script files to the container
COPY script.sh /app/script.sh
COPY script.py /app/script.py
COPY output.json /app/output.json

# Set the working directory
WORKDIR /app

# Make the script.sh executable
RUN chmod +x script.sh

# Expose port 7000 for Prometheus metrics
EXPOSE 7000

# Wait for 10 seconds and then execute the scripts
CMD sleep 10 && ./script.sh & python3 script.py
```
This Dockerfile defines the steps to build a Docker image that includes the necessary dependencies and runs two scripts, `script.sh` and `script.py`. Here's an explanation of the Dockerfile:

1. Use the latest Ubuntu image as the base image.

2. Update the package lists and install the `mtr` package using `apt-get`.

3. Install Python 3 and pip3 using `apt-get`.

4. Install the `prometheus_client` package using `pip3`.

5. Copy the `script.sh`, `script.py`, and `output.json` files from the local machine to the `/app` directory in the container.

6. Set the working directory to `/app`.

7. Make the `script.sh` file executable using `chmod +x`.

8. Expose port 7000 to allow access to the Prometheus metrics.

9. Use the `CMD` instruction to specify the command to run when the container starts. In this case, it waits for 10 seconds using `sleep` and then runs `script.sh` in the background (`&`) and `script.py` using `python3`.

This Dockerfile can be used to build a Docker image that includes the necessary dependencies and runs the provided scripts.

## Additional information for the docker file
```
 docker build -t your-docker-username/image-name:tag .
```
to push image on dockerhub
```
 docker push your-docker-username/image-name:tag
```
```
 docker run -p 7000:7000 your-docker-username/image-name:tag
```
## Kubernetes section

Now, to run the script and its metrics in the Kubernetes cluster, we must create and run the following files in order.
To Create Pods : script-exporter-deployment.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: script-exporter-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: script-exporter
  template:
    metadata:
      labels:
        app: script-exporter
    spec:
      containers:
        - name: script-container
          image: amin1374/scexporter:v2
          ports:
            - containerPort: 7000
          readinessProbe:
            tcpSocket:
              port: 7000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            tcpSocket:
              port: 7000
            initialDelaySeconds: 10
            periodSeconds: 15
```
