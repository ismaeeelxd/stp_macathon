import os
from flask import Flask
from config import Config 
from flask_pymongo import PyMongo 
from flask import jsonify

mongo = PyMongo()

def create_app(config_class=Config):

    app = Flask(__name__, instance_relative_config=True)

    app.config.from_object(config_class)
    upload_folder = app.config.get('UPLOAD_FOLDER', 'uploads')
    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder)
    print(f"{config_class.MONGO_URI}")
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass 

    mongo.init_app(app) 
    try:
        mongo.cx.server_info()
        print("MongoDB connection successful")
    except Exception as e:
        print("MongoDB connection failed:", e)




    from .routes import bp as main_blueprint
    app.register_blueprint(main_blueprint)

    @app.errorhandler(404)
    def not_found_error(error):
        return jsonify(error=str(error)), 404

    print(f"Flask App created with config: {config_class.__name__} using MongoDB and registered routes")
    return app
