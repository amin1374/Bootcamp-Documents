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
