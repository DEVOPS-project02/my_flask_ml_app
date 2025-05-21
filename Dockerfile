# Base image with better OpenCV support
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install required packages and Python
RUN apt-get update && apt-get install -y \
    build-essential cmake git pkg-config wget unzip curl gnupg lsb-release \
    libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev \
    libv4l-dev libxvidcore-dev libx264-dev libatlas-base-dev \
    gfortran python3-dev python3-pip ffmpeg libsm6 libxext6 libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python libraries
RUN pip3 install --upgrade pip
RUN pip3 install numpy

# WORKDIR for OpenCV build
WORKDIR /opt

# Download and unzip OpenCV + contrib
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.5.5.zip && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.5.5.zip && \
    unzip opencv.zip && unzip opencv_contrib.zip && \
    mv opencv-4.5.5 opencv && mv opencv_contrib-4.5.5 opencv_contrib

# Build OpenCV with Darknet support
RUN mkdir /opt/opencv/build && cd /opt/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_ENABLE_NONFREE=ON \
          -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules \
          -D BUILD_opencv_python3=ON \
          -D BUILD_EXAMPLES=OFF \
          -D WITH_DARKNET=ON \
          .. && \
    make -j$(nproc) && make install && ldconfig

# Test OpenCV build
RUN python3 -c "import cv2; print('OpenCV:', cv2.__version__)"

# App setup
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Copy source code
COPY . .

# Ensure upload folder exists
RUN mkdir -p static/uploads

# Download YOLOv3 weights and config
RUN mkdir -p models && \
    wget -nc https://pjreddie.com/media/files/yolov3.cfg -P models/ && \
    wget -nc https://pjreddie.com/media/files/yolov3.weights -P models/

# Expose Flask port
EXPOSE 5000

# Run the app
CMD ["python3", "app.py"]
