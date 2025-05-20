# Use an official Python base image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install OS-level dependencies (excluding terraform here)
RUN apt-get update && apt-get install -y \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libopencv-dev \
    ffmpeg \
    wget \
    curl \
    git \
    unzip \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add HashiCorp official repo and install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y terraform \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy requirements file and install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the entire project into the image
COPY . .

# Ensure uploads directory exists
RUN mkdir -p static/uploads

# Download YOLO model weights if not already present
RUN mkdir -p models && \
    test -f models/yolov3.weights || \
    wget https://pjreddie.com/media/files/yolov3.weights -P models/

# Expose the Flask default port
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
