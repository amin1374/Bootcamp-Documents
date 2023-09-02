### Phase 1
## Creating the Volumes
A database involves data. You need to read and write data. Therefore, you need to persist this data so that an application can access and use it anytime. Thus, when deploying a database service to Kubernetes, a pod is set to a volume to persist your data. Go ahead and create a db-persistent-volume.yaml file. In this file, create a resource to set up Persistent Volume (PV) as follows:

```
apiVersion: v1
# Kind for volume chain
kind: PersistentVolume
metadata:
  # Name the persistent chain
  name: postgresdb-persistent-volume
  # Labels for identifying PV
  labels:
    type: local
    app: postgresdb
spec:
  storageClassName: manual
  capacity:
    # PV Storage capacity
    storage: 8Gi
  # A db can write and read from volumes to multiple pods
  accessModes:
    - ReadWriteMany
  # Specify the path to persistent the volumes  
  hostPath:
    path: "/data/db"
```

To allow a cluster to request access to the data storage, you need to set up a PersistentVolumeClaim (PVC) to the corresponding Persistent Volume. PVC is bound to a PV. It ensures the pods created within the designated cluster can access a volume to store data.

To create PVC, add a new file and name it db-volume-claim.yaml. In this file create PVC as follows:
```
apiVersion: v1
# define a resource for volume chain
kind: PersistentVolumeClaim
metadata:
  # Name the volume chain
  name: db-persistent-volume-claim
spec:
  storageClassName: manual
  accessModes:
    # Allow ReadWrite to multiple pods
    - ReadWriteMany
  # PVC requesting resources
  resources:
    requests:
      # the PVC storage
      storage: 8Gi
```
## Creating Database Secrets
Databases require access control using passwords and users. You can use Kubernetes to create these credentials. To do this, use ConfigMap to create environment variables to store the database configurations.

You need to create a db-configmap.yaml file:

```
apiVersion: v1
# Kind for kubernets ConfigMap
kind: ConfigMap
metadata:
  # Name your ConfigMap
  name: db-secret-credentials
  labels:
    app: postgresdb
data:
  # User DB
  POSTGRES_DB: testDB
  # Db user
  POSTGRES_USER: testUser
  # Db password
  POSTGRES_PASSWORD: testPassword
```
## Creating the Deployment Resource
Deployment resource creates and manages a set of replicas of a pod to run an application on Kubernetes. On top of that, it specifies all the needed artifacts to execute the application. This includes your application image and ports to expose it.

Additionally, it also allows you to add volumes to the pods on the cluster. In this example, we have specified the volumes that PostgreSQL requires. PersistentVolumeClaim must be specified during deployment to ensure the cluster can access the storage and store data. Volumes must be attached to the pods.

Create a db-deployment.yaml and build a PostgreSQL deployment manifest as follows:

```
# Kubernetes API version
apiVersion: apps/v1
# Deployment object
kind: Deployment
metadata:
  # The name of the Deployment
  name: postgresdb
spec:
  # Replicas for this Deployment
  replicas: 3
  selector:
    # labels the pods
    matchLabels:
      app: postgresdb
  template:
    metadata:
      labels:
        # The label the pods created from the pod template should have
        app: postgresdb
    spec:
      containers:
        # The container name to execute pods
        - name: postgresdb
          # pull postgresimage from docker hub
          image: postgres
          ports:
            # Assign ports to expose container
            - containerPort: 5432
          envFrom:
            # Load the environment variables/PostgresSQL credentials
            - configMapRef:
                # This should be the ConfigMap name created ealier
                name: db-secret-credentials
          volumeMounts:
            # The volume mounts  for the container
            - mountPath: /var/lib/postgres/data
              name: db-data
      # Volumes attached to the pod
      volumes:
        - name: db-data
          persistentVolumeClaim:
            # reference the PersistentVolumeClaim
            claimName: db-persistent-volume-claim
```
## Creating the Service Resource
A service exposes a deployment. It provides a stable network endpoint for accessing a cluster. To create a service resource, add a db-service.yaml file and include the following:

```
apiVersion: v1
kind: Service
metadata:
  name: postgresdb
spec:
  type: ClusterIP
  selector:
    app: postgresdb
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
```
## Deploying PostgreSQL
You now have the needed resources. It’s time to run them on Kubernetes. First, you need to deploy the volumes before creating the pods. Below are the commands required to do so:

Deploy the PV:
```
kubectl apply -f db-persistent-volume.yaml
```
Deploy the PVC
```
kubectl apply -f db-volume-claim.yaml
```
The environment variables are needed by the cluster. Deploy them as follows:
```
kubectl apply -f db-configmap.yaml
```
Next, create the deployment and add pods replicas.
```
kubectl apply -f db-deployment.yaml
```
Finaly run the service to expose the cluster
```
kubectl apply -f db-service.yaml
```

## To check the database deployment, run the following command:
```
kubectl exec -it postgresdb-5b9bf77c46-6xhx2 -- psql -h localhost -U testUser --password -p 5432 testDB
```

### Phase 2

## Change the script and convert to Docker image
Considering that the database information is stored in the cluster as a configmap.
```
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
```
## Dokcerfile
```
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
```
now run this command:
```
docker build -t amin1374/script:v1 .
```
After the project image is created, we will upload it to Docker Hub.
```
docker push amin1374/script:v1
```
Now we will make the corresponding Docker image private.
To use a private image in Kubernetes, we need an account service.

In K8s To create the DockerHub secret, use the following command:

```
kubectl create secret docker-registry dockerhub-secret --docker-server=https://index.docker.io/v1/ --docker-username=xxxxx --docker-password=xxxxxx --docker-email=xxxx@gmail.com
```
