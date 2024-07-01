# Use the official Node.js image as the base image for building
FROM node:lts-slim AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json files to the working directory
COPY package.json ./
RUN npm i --package-lock-only

# Install the project dependencies
RUN npm ci

# Copy the rest of the project files to the working directory
COPY . .

# Build the Next.js application and export it as static files
RUN npm run build

# Use the official Nginx image as the base image for serving
FROM nginx:stable-alpine

# Copy the built files from the previous stage to the nginx html directory
COPY --from=build /app/dist /usr/share/nginx/html

# Copy the nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Forward Nginx logs to Docker's stdout and stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Expose the port on which the application will run
EXPOSE 80

# Start the Nginx server
CMD ["nginx", "-g", "daemon off;"]