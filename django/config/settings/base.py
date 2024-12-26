import os
from django.core.management.utils import get_random_secret_key

# Base settings
DEBUG = os.getenv("DEBUG", "True") == "True"

ALLOWED_HOSTS = os.getenv("ALLOWED_HOSTS", "*").split(",") if not DEBUG else ["*"]

# Generate or fetch SECRET_KEY
SECRET_KEY = os.getenv("SECRET_KEY", get_random_secret_key())

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django_elasticsearch_dsl',
    'app',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
]

ROOT_URLCONF = 'config.urls'
WSGI_APPLICATION = 'config.wsgi.application'

# Static files
STATIC_URL = '/static/'

# TEMPLATES configuration
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../app/templates')],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# Celery Settings
CELERY_BROKER_URL = 'redis://redis:6379/0'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'

# Database configuration
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('POSTGRES_DB', 'mydb'),
        'USER': os.getenv('POSTGRES_USER', 'myuser'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD', 'mypassword'),
        'HOST': os.getenv('DB_HOST', 'db'),  # The service name in docker-compose
        'PORT': os.getenv('DB_PORT', '5432'),
    }
}

# Elasticsearch Settings
ELASTICSEARCH_DSL = {
    'default': {
        'hosts': os.getenv('ELASTICSEARCH_HOST', 'http://elasticsearch:9200'),
    },
}
