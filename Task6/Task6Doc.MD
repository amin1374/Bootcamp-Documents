
## Prometheus Bash Script Exporter and Monitoring on k8s cluster

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
To Create Pods : `script-exporter-deployment.yaml`

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
```
kubectl apply -f script-exporter-deployment.yaml
```
Now we run the service so that the pod is available from outside the cluster.
 ` script-exporter-service.yaml`
```
apiVersion: v1
kind: Service
metadata:
  name: script-exporter-service
  labels:
    app: script-exporter
spec:
  type: NodePort
  selector:
    app: script-exporter
  ports:
    - protocol: TCP
      port: 7000
      targetPort: 7000
      nodePort: 30003
```
```
kubectl apply -f script-exporter-service.yaml
```
To Use Prometheus Service Descovery we need create servicemonitor.yaml
`script-service-monitor.yaml`
```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: script-exporter-service-monitor
  namespace: default
  labels:
    release: mon
spec:
  selector:
    matchExpressions:
      - key: app
        operator: Regex
        values:
          - "^script-exporter.*$"
  endpoints:
    - port: metrics
      interval: 30s
      path: /metrics
  namespaceSelector:
    matchNames:
      - default
```
```
kubectl apply -f script-service-monitor.yaml
```
## Prometheus service descovery


Sample Exporter data:

```
# HELP python_gc_objects_collected_total Objects collected during gc
# TYPE python_gc_objects_collected_total counter
python_gc_objects_collected_total{generation="0"} 202.0
python_gc_objects_collected_total{generation="1"} 173.0
python_gc_objects_collected_total{generation="2"} 0.0
# HELP python_gc_objects_uncollectable_total Uncollectable objects found during GC
# TYPE python_gc_objects_uncollectable_total counter
python_gc_objects_uncollectable_total{generation="0"} 0.0
python_gc_objects_uncollectable_total{generation="1"} 0.0
python_gc_objects_uncollectable_total{generation="2"} 0.0
# HELP python_gc_collections_total Number of times this generation was collected
# TYPE python_gc_collections_total counter
python_gc_collections_total{generation="0"} 42.0
python_gc_collections_total{generation="1"} 3.0
python_gc_collections_total{generation="2"} 0.0
# HELP python_info Python platform information
# TYPE python_info gauge
python_info{implementation="CPython",major="3",minor="10",patchlevel="12",version="3.10.12"} 1.0
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 2.54500864e+08
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 2.2351872e+07
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.69450253552e+09
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 2.1
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 6.0
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 1.048576e+06
# HELP domain_rtt Round-trip time for the domain
# TYPE domain_rtt gauge
domain_rtt{domain="zoomit.ir"} 3.0
domain_rtt{domain="google.com"} 27.31
domain_rtt{domain="arvancloud.ir"} 3.2
domain_rtt{domain="kavenegar.com"} 3.93
# HELP domain_packet_loss Packet loss for the domain
# TYPE domain_packet_loss gauge
domain_packet_loss{domain="zoomit.ir"} 0.0
domain_packet_loss{domain="google.com"} 0.0
domain_packet_loss{domain="arvancloud.ir"} 0.0
domain_packet_loss{domain="kavenegar.com"} 0.0
# HELP domain_jitter Jitter for the domain
# TYPE domain_jitter gauge
domain_jitter{domain="zoomit.ir"} 0.18
domain_jitter{domain="google.com"} 0.82
domain_jitter{domain="arvancloud.ir"} 0.05
domain_jitter{domain="kavenegar.com"} 0.72
# HELP domain_received_info Received value for the domain
# TYPE domain_received_info gauge
domain_received_info{domain="kavenegar.com",received="kavenegar.com"} 1.0
```
## Grafana Dashboard
![alt text](https://github.com/amin1374/NeshanDocuments/blob/master/Task6/pictures/Grafana-dash.png)

## Headless Service
To create a headless service, we need to make changes in the service file. Here, because we wanted to have a new pod for this service separately in addition to the previous pods, we repeat the steps again.
`newexpo-deployment.yaml`
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: newexpo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: newexpo
  template:
    metadata:
      labels:
        app: newexpo
    spec:
      containers:
        - name: newexpo
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
```
kubectl apply -f newexpo-deployment.yaml
```
service file
`newexpo-service.yaml`
```
apiVersion: v1
kind: Service
metadata:
  name: newexpo
  labels:
    app: newexpo
spec:
  clusterIP: None
  selector:
    app: newexpo
  ports:
    - protocol: TCP
      port: 7000
      targetPort: 7000
````
```
kubectl apply -f newexpo-service.yaml
```
To use the Prometheus discovery service, we need to create a monitor service file
`newexpo-servicemonitor.yaml`
```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: newexpo
  namespace: default
  labels:
    release: mon
spec:
  selector:
    matchLabels:
      app: newexpo
  endpoints:
    - port: metrics
      interval: 30s
      path: /metrics
  namespaceSelector:
    matchNames:
      - default
```
```
kubectl apply -f newexpo-servicemonitor.yaml
```
![alt text](https://github.com/amin1374/NeshanDocuments/blob/master/Task6/pictures/Headless-targets.png)
## Kubernetes Endpoint
In order to be able to add a service outside the Kubernetes cluster to Prometheus inside the cluster, we need to create the following services.

In this example, we want to add Grafana metrics that are on a server outside the cluster network to Prometheus inside the cluster.
`service-ex.yaml``
```
kind: Service
apiVersion: v1
metadata:
 name: grafana-exporter-external
 labels:
    app: grafana-exporter-external
spec:
 type: ClusterIP
 ports:
 - name: metrics
   port: 3000
   targetPort: 3000
```
```
kubectl apply -f service-ex.yaml
```
`end-svc-ex.yaml`
```
kind: Endpoints
apiVersion: v1
metadata:
 name: grafana-exporter-external
subsets:
- addresses:
  - ip: 129.151.223.94
  ports:
  - name: metrics
    port: 3000
    protocol: TCP
```
```
kubectl apply -f end-svc-ex.yaml
```
To Use Service Dicovery
`svc-monitor.yaml`
```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: grafana-exporter-external
  namespace: default
  labels:
    release: mon
spec:
  endpoints:
  - interval: 30s
    port: metrics
  selector:
    matchLabels:
      app: grafana-exporter-external
```
```
kubectl apply -f svc-monitor.yaml
```
![alt text](https://github.com/amin1374/NeshanDocuments/blob/master/Task6/pictures/Endpoint-Target.png)
