# Stage 1: Build the Next.js app
FROM node:18-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Next.js app
RUN npm run build

# Stage 2: Serve the app with NGINX
FROM node:18-alpine

# Install NGINX
RUN apk add --no-cache nginx

# Set the working directory for NGINX
WORKDIR /usr/share/nginx/html

# Copy the built app from the builder stage
COPY --from=builder /app/.next /usr/share/nginx/html/.next
COPY --from=builder /app/public /usr/share/nginx/html/public
COPY --from=builder /app/package*.json ./
COPY --from=builder /app ./

# Copy the NGINX configuration template
COPY nginx.conf.template /etc/nginx/nginx.conf

# Install dependencies for production
RUN npm install --only=production

# Expose the port NGINX is listening on
EXPOSE 80

# Start NGINX and Next.js
CMD ["sh", "-c", "npm run start & nginx -g 'daemon off;'"]
