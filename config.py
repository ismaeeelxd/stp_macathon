# config.py
import os
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))

class Config:
    """Base configuration settings."""
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'SECRET_KEY'
    MONGO_URI = os.environ.get('MONGO_URI') 
    if MONGO_URI and 'mongodb+srv://' in MONGO_URI:
        if '?' not in MONGO_URI:
            MONGO_URI += '?'
        else:
            MONGO_URI += '&'
        MONGO_URI += 'ssl=true&ssl_cert_reqs=CERT_NONE'
    DEBUG = True
    UPLOAD_FOLDER = os.path.join(basedir, 'uploads') 

    # Add other configurations like mail server settings if needed
    # MAIL_SERVER = os.environ.get('MAIL_SERVER')
    # MAIL_PORT = int(os.environ.get('MAIL_PORT') or 25)
    # MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS') is not None
    # MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    # MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    # ADMINS = ['your-email@example.com']

