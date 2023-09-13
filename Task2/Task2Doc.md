## Prerequisites
- Docker installed on your machine
- Basic understanding of Docker and Docker Compose

## Steps

### 1. Clone the Battleships Repository
Clone the Battleships repository from GitHub using the following command:
```
git clone https://github.com/kubowania/battleships
```
### 2. Dockerize the Battleships Application
Navigate to the cloned repository and create a `Dockerfile` in the root directory with the following content:
```
# Use the official Node.js image as base
FROM node:14

# Create app directory
WORKDIR /app

# Copy package.json and package-lock.json to install app dependencies
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy app source code
COPY . .

# Expose port 3000
EXPOSE 3000

# Create a new user and switch to that user
RUN groupadd -r myuser && useradd -r -g myuser myuser
USER myuser

# Define command to run the app
CMD [ "node", "server.js" ]
```
Optional: build a Docker image by running the following command:
```
docker build -t battleships .
```
To run without Docker Compose, we use the following command
```
sudo docker run -d -p 3000:3000 amin1374/battelpro
```
The Dockerfile you provided is a basic Dockerfile for a Node.js application. It does the following:

* **FROM node:14** - This line tells Docker to use the official Node.js image as the base image for the new image.
* **WORKDIR /app** - This line creates a directory called `/app` inside the container and sets it as the working directory.
* **COPY package*.json ./** - This line copies the `package.json` and `package-lock.json` files from the host machine to the `/app` directory in the container. These files are used to install the application's dependencies.
* **RUN npm install** - This line runs the `npm install` command in the container to install the application's dependencies.
* **COPY . .** - This line copies the entire contents of the current directory on the host machine to the `/app` directory in the container. This includes the application's source code and any other files.
* **EXPOSE 3000** - This line tells Docker to expose port 3000 on the container. This is the port that the application will listen on.
* **RUN groupadd -r myuser && useradd -r -g myuser myuser** - This line creates a new user called `myuser` and adds it to the `myuser` group. This is useful for security purposes, as it prevents the application from running as root.
* **USER myuser** - This line tells Docker to run the application as the `myuser` user.
* **CMD [ "node", "server.js" ]** - This line defines the command that will be run when the container starts. In this case, the application's `server.js` file will be executed.

### 3. Create a Reverse Proxy Configuration
Create a `nginx.conf` file in the root directory with the following content:
```
server {
    listen 80;
    server_name bootcamp.neshan.ir;

    location / {
        proxy_pass http://node-app:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```
## 4. Create a Docker Compose File
Create a `docker-compose.yml` file in the root directory with the following content:

```
version: '3'
services:
  node-app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - 3000
    networks:
      - app-network

  nginx:
    image: nginx
    ports:
      - 4444:80
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    networks:
      - app-network
    depends_on:
      - node-app

networks:
  app-network:
    driver: bridge
```
### 5. Deploy the Application with Docker Compose
Run the following command to deploy the Battleships application and the reverse proxy:
```
docker-compose up -d
```
### 6. Update `/etc/hosts` File
To ensure that your system can resolve the `bootcamp.neshan.ir` domain locally, you need to update the `/etc/hosts` file. Open the file with a text editor and add the following line at the end:
```
127.0.0.1 bootcamp.neshan.ir
```
Save the file.


### 7. Access the Battleships Game
Open your browser and navigate to [http://bootcamp.neshan.ir:4444) to access the Battleships game.

![alt text](https://github.com/amin1374/NeshanDocuments/blob/master/Task2/scren.png)





- To stop and remove the containers, networks, and volumes defined in the `docker-compose.yml` file, run:
```
docker-compose down
```


