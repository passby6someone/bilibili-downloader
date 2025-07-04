# Stage 1: Build the application and install dependencies
FROM node:16-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the application source code
COPY server.js .

# Stage 2: Create the final image
FROM node:16-alpine AS final

WORKDIR /app

# Install curl, which is a lightweight dependency
RUN apk add --no-cache curl

# Copy FFmpeg and ffprobe from a static ffmpeg image
COPY --from=jrottenberg/ffmpeg:4.1-alpine /usr/local/bin/ffmpeg /usr/local/bin/
COPY --from=jrottenberg/ffmpeg:4.1-alpine /usr/local/bin/ffprobe /usr/local/bin/
RUN chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

# Copy installed dependencies and source code from the builder stage
COPY --from=builder /app .

# Expose the application port
EXPOSE 5577

# Create a volume for persistent data storage
# The user should map this volume using -v or docker-compose
VOLUME /app/content

# Set the default command to start the application
CMD [ "node", "server.js" ] 