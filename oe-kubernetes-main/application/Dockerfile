# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Update package lists and install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    && pip install Flask

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY src/* /app

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run app.py when the container launches
CMD ["python3", "server.py"]
