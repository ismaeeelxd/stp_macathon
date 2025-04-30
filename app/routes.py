from flask import (
    request,
    jsonify, 
    send_file, 
    abort,
    Blueprint 
)
import os
from app import services 
from app.image_processor import submit as process_image
import io 
bp = Blueprint('main', __name__)

import traceback
from flask import request, jsonify, abort, current_app

@bp.route('/predict', methods=["POST"])
def predict_prescription():
    # Check if the post request has the file part
    if 'file' not in request.files:
        abort(400, description="No file part in the request.")

    file = request.files['file']

    # If the user does not select a file, the browser submits an
    # empty file without a filename.
    if file.filename == '':
        abort(400, description="No selected file.")

    # Assuming services.allowed_file checks the file extension
    # Replace services.allowed_file and services.secure_filename if needed
    # e.g., define allowed_file locally and from werkzeug.utils import secure_filename
    if file and services.allowed_file(file.filename):
        filename = services.secure_filename(file.filename) # Sanitize filename
        # Use the configured UPLOAD_FOLDER from the app context
        # upload_folder = current_app.config['UPLOAD_FOLDER']
        # if not upload_folder:
        #      # Handle case where UPLOAD_FOLDER is not configured
        #      abort(500, description="Upload folder is not configured.")
        upload_folder = current_app.config['UPLOAD_FOLDER'] # Get path from config

        temp_filepath = os.path.join(upload_folder, filename)

        try:
            file.save(temp_filepath) # Save the uploaded file temporarily
            print(f"File saved to: {temp_filepath}")

            # Call the processing function
            results = process_image(temp_filepath) # Pass the path

            # Handle potential errors from processing
            if results is None:
                abort(500, description="Error processing the image.")

            print(f"Processing results: {results}")
            return jsonify({"results": results})

        except Exception as e:
            # Log the exception for debugging
            # current_app.logger.error(f"An error occurred: {e}") # Use app logger if configured
            print(f"error occured : {e}")
            traceback.print_exc()
            abort(500, description=f"An internal server error occurred: {e}")
        finally:
            # Clean up the temporary file
            if os.path.exists(temp_filepath):
                try:
                    os.remove(temp_filepath)
                    print(f"Temporary file removed: {temp_filepath}")
                except Exception as e_clean:
                    # current_app.logger.error(f"Error removing temporary file {temp_filepath}: {e_clean}")
                    print(f"Error removing temporary file {temp_filepath}: {e_clean}") # Print error if logger not set up
    else:
        # Added else block based on previous examples for disallowed files
        abort(400, description="File type not allowed.")





@bp.route('/upload', methods=['POST'])
def upload_image_api():

    if 'file' not in request.files:
        return jsonify({'error': 'No file part in the request.'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No selected file.'}), 400

    if file:
        file_id = services.save_uploaded_image(file)

        if file_id:
            return jsonify({
                'message': 'File uploaded successfully!',
                'file_id': str(file_id)
            }), 201
        else:
            # Return JSON error response (e.g., bad file type, save error)
            # Use 400 for client errors (like wrong file type)
            # Use 500 for server errors (like GridFS save failure)
            # Service layer could potentially return more specific errors
            return jsonify({'error': 'Image upload failed. Check file type or server logs.'}), 400 # Or 500

    return jsonify({'error': 'An unexpected error occurred.'}), 500


# --- API Endpoint to Retrieve/View an Image ---
@bp.route('/image/<file_id>', methods=['GET'])
def view_image_api(file_id):

    image_data = services.repositories.get_image_data(file_id) # Assuming service imports repo

    if image_data:
        # Use send_file to send the raw image data back
        # Flutter app can use this URL directly in Image.network or fetch bytes
        return send_file(
            io.BytesIO(image_data.read()), # Read data into memory stream
            mimetype=image_data.content_type,
            as_attachment=False # Display inline if possible
        )
    else:
        # If file not found or error, return 404 Not Found
        # jsonify can be used for a JSON 404 response if preferred:
        # return jsonify({'error': 'Image not found'}), 404
        abort(404, description="Image not found")

# Note: The index route ('/') that redirected to upload is removed as it's not needed for an API.
# Note: Removed render_template and other template-related imports/logic.
