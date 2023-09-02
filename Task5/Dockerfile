# Use a base image with the necessary dependencies
FROM ubuntu:latest

# Install required packages
RUN apt-get update && apt-get install -y mtr postgresql-client

# Copy the script to the container
COPY script.sh /app/

# Set the working directory
WORKDIR /app

# Make the script executable
RUN chmod +x script.sh

# Set environment variables for database connection
ENV DB_HOST=""
ENV DB_PORT=""
ENV DB_NAME=""
ENV DB_USER=""
ENV DB_PASSWORD=""

# Run the script when the container starts
CMD ["./script.sh"]
