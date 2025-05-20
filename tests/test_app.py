import pytest
import os
from app import app, allowed_file, detect_objects, classify_arecanut
import numpy as np
import cv2
from werkzeug.datastructures import FileStorage
from io import BytesIO

# Fixtures for setting up the Flask client
@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

# Test allowed file function
def test_allowed_file():
    assert allowed_file('test.jpg') == True
    assert allowed_file('test.png') == True
    assert allowed_file('test.txt') == False

# Test the home page
def test_index(client):
    """Test the home page loads correctly"""
    response = client.get('/')
    assert response.status_code == 200
    assert b"Welcome to My App" in response.data

# Test file upload (valid file)
def test_upload_file(client):
    data = {
        'file': (BytesIO(b"test image content"), 'test.jpg')
    }
    response = client.post('/upload', content_type='multipart/form-data', data=data)
    assert response.status_code == 200
    assert b"result_" in response.data  # result image should be returned

# Test file upload (invalid file)
def test_upload_invalid_file(client):
    data = {
        'file': (BytesIO(b"test invalid content"), 'test.txt')
    }
    response = client.post('/upload', content_type='multipart/form-data', data=data)
    assert response.status_code == 400

# Test object detection functionality
def test_detect_objects():
    image = np.zeros((640, 480, 3), dtype=np.uint8)  # Black image (dummy)
    detected_image = detect_objects(image)
    assert detected_image is not None
    assert detected_image.shape == image.shape

# Test classification of Arecanut
def test_classify_arecanut():
    image = np.zeros((128, 128, 3), dtype=np.uint8)  # Dummy image for classification
    result = classify_arecanut(image)
    assert result in ["Rashi", "Gorabalu"]  # The model should predict one of these classes

# Test upload route (invalid form, no file)
def test_upload_no_file(client):
    response = client.post('/upload')
    assert response.status_code == 400
    assert b"No file uploaded" in response.data
