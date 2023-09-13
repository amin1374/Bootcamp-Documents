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
