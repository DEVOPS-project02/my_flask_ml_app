import os
from flask import Flask, render_template, request, send_from_directory
import cv2
import numpy as np
import tensorflow as tf
from werkzeug.utils import secure_filename

# Load the YOLO model (object detection)
net = cv2.dnn.readNet('models/yolov3.weights', 'models/yolov3.cfg')

# Load the Arecanut classifier model
classifier_model = tf.keras.models.load_model('models/arecanut_classifier.h5')

# Create Flask app
app = Flask(__name__)

# Configure upload and static folder paths
app.config['UPLOAD_FOLDER'] = 'static/uploads/'
app.config['TEMPLATES_FOLDER'] = 'templates'

# Check for valid image extensions
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'jpg', 'jpeg', 'png'}

# Serve CSS files from static folder
@app.route('/static/css/<path:filename>')
def serve_css(filename):
    return send_from_directory('static/css', filename)

# Serve JS files from static folder
@app.route('/static/js/<path:filename>')
def serve_js(filename):
    return send_from_directory('static/js', filename)

# Serve images from static/image folder (updated)
@app.route('/static/image/<path:filename>')
def serve_images(filename):
    return send_from_directory('static/image', filename)

# Object detection function (no class names displayed)
def detect_objects(image):
    height, width = image.shape[:2]
    blob = cv2.dnn.blobFromImage(image, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
    net.setInput(blob)
    outputs = net.forward(net.getUnconnectedOutLayersNames())

    boxes, confidences = [], []

    for out in outputs:
        for detection in out:
            scores = detection[5:]
            confidence = max(scores)
            if confidence > 0.5:  # Confidence threshold
                center_x = int(detection[0] * width)
                center_y = int(detection[1] * height)
                w = int(detection[2] * width)
                h = int(detection[3] * height)
                x = int(center_x - w / 2)
                y = int(center_y - h / 2)

                boxes.append([x, y, w, h])
                confidences.append(float(confidence))

    indices = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4)  # Non-Max Suppression

    for i in range(len(boxes)):
        if i in indices:
            x, y, w, h = boxes[i]
            cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)  # Draw bounding box

    return image

# Classification function for Arecanut
def classify_arecanut(image):
    img = cv2.resize(image, (128, 128))  # Resize to the input size of the model
    img = img.astype('float32') / 255.0  # Normalize the image
    img = np.expand_dims(img, axis=0)  # Add batch dimension
    prediction = classifier_model.predict(img)
    return "Rashi" if np.argmax(prediction) == 0 else "Gorabalu"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_image():
    if 'file' not in request.files:
        return "No file uploaded", 400
    file = request.files['file']
    if file.filename == '':
        return "No selected file", 400
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # Load the uploaded image
        image = cv2.imread(filepath)

        # Object detection
        detected_image = detect_objects(image)

        # Perform classification on the full image
        classification = classify_arecanut(detected_image)

        # Save the processed image with bounding boxes
        result_path = os.path.join(app.config['UPLOAD_FOLDER'], 'result_' + filename)
        cv2.imwrite(result_path, detected_image)

        return render_template('index.html', result=classification, image_path=result_path)
    return "Invalid file format", 400

if __name__ == '__main__':
    app.run(debug=True)
