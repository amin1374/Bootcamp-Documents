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
