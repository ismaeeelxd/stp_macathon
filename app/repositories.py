# app/repositories.py
from app import mongo # Import the initialized PyMongo object
from gridfs import GridFS, NoFile # Import GridFS components
from bson.objectid import ObjectId
from datetime import datetime

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

def save_prescription_results(image_id, results):
    """
    Save prescription processing results to MongoDB
    """
    try:
        prescription_doc = {
            'image_id': image_id,
            'results': results,
            'created_at': datetime.utcnow()
        }
        result = mongo.db.prescriptions.insert_one(prescription_doc)
        print(f"Saved prescription results with ID: {result.inserted_id}")
        return result.inserted_id
    except Exception as e:
        print(f"Error saving prescription results: {e}")
        return None
        

def login(email, password):
    """
    Authenticate user credentials
    """
    try:
        user = mongo.db.users.find_one({'email': email, 'password': password})
        return user is not None
    except Exception as e:
        print(f"Error authenticating user: {e}")
        return False

def create_user(email, password):
    """
    Create a new user in the database
    """
    try:
        user = {
            'email': email,
            'password': password,
            'created_at': datetime.utcnow()
        }
        result = mongo.db.users.insert_one(user)
        return result.inserted_id is not None   
    except Exception as e:
        print(f"Error creating user: {e}")
        return False

def update_prescription_results(image_id, results):
    """
    Update prescription results for a given image ID
    """
    try:
        prescription = mongo.db.prescriptions.find_one({'image_id': image_id})
        if prescription:
            prescription['results'] = results
            prescription['updated_at'] = datetime.utcnow()
            result = mongo.db.prescriptions.update_one(
                {'image_id': image_id},
                {'$set': prescription}
            )
            return result.modified_count > 0
        else:
            return False
    except Exception as e:
        print(f"Error updating prescription results: {e}")
        return False
        
