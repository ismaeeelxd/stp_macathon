# app/repositories.py
from app import mongo # Import the initialized PyMongo object
from gridfs import GridFS, NoFile # Import GridFS components
from bson.objectid import ObjectId

def save_image(file_storage, filename, content_type):

    try:
        fs = GridFS(mongo.db)
        # Save the file data using fs.put()
        # file_storage.read() gets the binary data
        # file_storage.seek(0) # Reset stream position if read multiple times (usually not needed here)
        file_id = fs.put(
            file_storage.read(), # Read the file stream
            filename=filename,
            contentType=content_type
        )
        print(f"Saved file '{filename}' to GridFS with ID: {file_id}")
        return file_id
    except Exception as e:
        print(f"Error saving to GridFS: {e}") # Use proper logging in a real app
        return None

def get_image_data(file_id_str):
    try:
        fs = GridFS(mongo.db)
        obj_id = ObjectId(file_id_str)
        grid_out = fs.get(obj_id)
        return grid_out
    except NoFile:
        print(f"No file found in GridFS with ID: {file_id_str}")
        return None
    except Exception as e:
        print(f"Error retrieving from GridFS (ID: {file_id_str}): {e}")
        return None
