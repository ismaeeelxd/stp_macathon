# app/services.py
from . import repositories
from werkzeug.utils import secure_filename

# from image_processor import submit as process_image


ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def save_uploaded_image(file_storage):

    if not file_storage:
        print("No file storage object provided.")
        return None

    if file_storage.filename == '':
        print("No selected file.")
        return None

    if allowed_file(file_storage.filename):
        filename = secure_filename(file_storage.filename)
        content_type = file_storage.content_type

        print(f"Attempting to save file: {filename}, type: {content_type}")
        file_id = repositories.save_image(file_storage, filename, content_type)
        return file_id
    else:
        print(f"File type not allowed: {file_storage.filename}")
        return None
    

def login(email, password):
    return repositories.login(email, password)

def create_user(email, password):
    return repositories.create_user(email, password)


