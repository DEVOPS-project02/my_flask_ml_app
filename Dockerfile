# Use an official Python base image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    ffmpeg \
    wget \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Uninstall conflicting OpenCV versions and install required version
RUN pip install --upgrade pip && \
    pip uninstall -y opencv-python opencv-contrib-python && \
    pip install opencv-python==4.7.0.72 opencv-contrib-python==4.7.0.72
    pip install -r requirements.txt

# Copy application code
COPY . .

# Ensure uploads folder exists
RUN mkdir -p static/uploads

# Download YOLOv3 weights and config
RUN mkdir -p models && \
    wget -nc https://pjreddie.com/media/files/yolov3.cfg -P models/ && \
    wget -nc https://pjreddie.com/media/files/yolov3.weights -P models/

# Expose port for Flask
EXPOSE 5000

# Run the Flask app
CMD ["python", "app.py"]
