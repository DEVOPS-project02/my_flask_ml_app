# Use Windows Server Core as base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 `
    PYTHONUNBUFFERED=1 `
    PYTHON_VERSION=3.10.11

# Install Python
RUN powershell -Command `
    Invoke-WebRequest -Uri https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe -OutFile python-installer.exe ; `
    Start-Process python-installer.exe -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -NoNewWindow -Wait ; `
    Remove-Item -Force python-installer.exe

# Verify Python installed
RUN python --version

# Install pip packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create workdir
WORKDIR /app

# Copy app files
COPY . .

# Make uploads directory
RUN mkdir static\uploads

# Download YOLOv3 weights and config
RUN powershell -Command `
    Invoke-WebRequest -Uri https://pjreddie.com/media/files/yolov3.weights -OutFile models\yolov3.weights ; `
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolov3.cfg -OutFile models\yolov3.cfg

# Expose Flask port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
