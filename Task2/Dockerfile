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
