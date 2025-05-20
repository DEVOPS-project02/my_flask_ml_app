from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import os

# Setup WebDriver
def setup_driver():
    driver = webdriver.Chrome()  # You can use other drivers (e.g., Firefox, Edge)
    driver.get('http://127.0.0.1:5000/')  # Assuming Flask app is running locally
    return driver

# Test if the home page loads correctly
def test_home_page():
    driver = setup_driver()

    # Wait until the page is fully loaded and elements are available
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.TAG_NAME, 'h1'))
    )

    # Check for the title of the page
    title = driver.title
    assert "My App" in title  # Check if the page title is correct

    # Verify that the home page contains a welcome message
    welcome_message = driver.find_element(By.TAG_NAME, 'h1')
    assert "Welcome to My App" in welcome_message.text

    driver.quit()

# Test if the uploaded image is displayed after upload and classification
def test_image_upload_and_classification():
    driver = setup_driver()

    # Find the file input element and upload an image
    upload_button = driver.find_element(By.ID, 'file')
    upload_button.send_keys(os.path.abspath('tests/test_image.jpg'))  # Path to the test image

    # Find the submit button and click to upload the image
    submit_button = driver.find_element(By.ID, 'submit-button')  # Assuming the button has this ID
    submit_button.click()

    # Wait for the results to appear (wait until result message is visible)
    WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located((By.ID, 'result-message'))
    )

    # Verify that a classification result (e.g., "Rashi" or "Gorabalu") is displayed
    result_message = driver.find_element(By.ID, 'result-message')
    assert "Rashi" in result_message.text or "Gorabalu" in result_message.text

    # Verify that the processed image is shown
    image_result = driver.find_element(By.ID, 'result-image')  # Assuming this ID is used to display the image
    assert image_result.is_displayed()  # Ensure the image is visible

    driver.quit()

# Test if the form inputs are reset after successful upload
def test_form_reset_after_upload():
    driver = setup_driver()

    # Find the file input element and upload an image
    upload_button = driver.find_element(By.ID, 'file')
    upload_button.send_keys(os.path.abspath('tests/test_image.jpg'))  # Path to the test image

    # Find the submit button and click to upload the image
    submit_button = driver.find_element(By.ID, 'submit-button')
    submit_button.click()

    # Wait for the results to appear
    WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located((By.ID, 'result-message'))
    )

    # Check if the form is reset after submission
    file_input = driver.find_element(By.ID, 'file')
    assert file_input.get_attribute('value') == ""  # Form input should be empty

    driver.quit()

# Test if a user can upload an invalid file and see an error message
def test_invalid_file_upload():
    driver = setup_driver()

    # Find the file input element and upload an invalid file (e.g., text file)
    upload_button = driver.find_element(By.ID, 'file')
    upload_button.send_keys(os.path.abspath('tests/test_invalid.txt'))  # Path to an invalid file

    # Find the submit button and click to upload
    submit_button = driver.find_element(By.ID, 'submit-button')
    submit_button.click()

    # Wait for the error message to appear
    WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located((By.CLASS_NAME, 'error-message'))
    )

    # Check if the error message is displayed (assuming an element with this class shows the error)
    error_message = driver.find_element(By.CLASS_NAME, 'error-message')
    assert "Invalid file format" in error_message.text

    driver.quit()

# Test if the file input is reset when a user cancels the upload
def test_cancel_file_upload():
    driver = setup_driver()

    # Find the file input element and upload an image
    upload_button = driver.find_element(By.ID, 'file')
    upload_button.send_keys(os.path.abspath('tests/test_image.jpg'))  # Path to the test image

    # Find the cancel button or reset option (e.g., a clear button)
    cancel_button = driver.find_element(By.ID, 'cancel-upload')  # Assuming an ID like this exists
    cancel_button.click()

    # Verify that the input has been reset (file input should be empty)
    file_input = driver.find_element(By.ID, 'file')
    assert file_input.get_attribute('value') == ""  # Form input should be empty

    driver.quit()

# Test if the app handles page load gracefully when there is no image uploaded
def test_no_upload():
    driver = setup_driver()

    # Try submitting without uploading a file
    submit_button = driver.find_element(By.ID, 'submit-button')
    submit_button.click()

    # Wait for the error message to appear
    WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located((By.CLASS_NAME, 'error-message'))
    )

    # Check for error message
    error_message = driver.find_element(By.CLASS_NAME, 'error-message')
    assert "No file uploaded" in error_message.text

    driver.quit()
#pytest tests/test_selenium_v2.py --maxfail=5 --disable-warnings -q

#