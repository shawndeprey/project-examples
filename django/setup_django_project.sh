#!/bin/bash

# Create directories
mkdir -p ./config/settings
mkdir -p ./app/migrations
mkdir -p ./app/models
mkdir -p ./app/views
mkdir -p ./app/tasks
mkdir -p ./app/documents
mkdir -p ./app/management
mkdir -p ./app/management/commands
mkdir -p ./app/serializers
mkdir -p ./app/serializers/api
mkdir -p ./app/tests
mkdir -p ./app/templates
mkdir -p ./app/static/css
mkdir -p ./app/static/js

# Add .keep to empty directories
touch ./app/templates/.keep
touch ./app/static/css/.keep
touch ./app/static/js/.keep
touch ./app/serializers/.keep
touch ./app/serializers/api/.keep

# Create files for config
touch ./config/__init__.py
touch ./config/asgi.py
touch ./config/wsgi.py
touch ./config/urls.py
touch ./config/settings/__init__.py
touch ./config/settings/base.py
touch ./config/settings/development.py
touch ./config/settings/production.py

# Create files for app
touch ./app/__init__.py
touch ./app/admin.py
touch ./app/apps.py
touch ./app/migrations/__init__.py
touch ./app/models/__init__.py
touch ./app/views/__init__.py
touch ./app/views/index.py
touch ./app/tasks/__init__.py
touch ./app/tasks/example.py
touch ./app/tests/__init__.py
touch ./app/tests/test_views.py
touch ./app/urls.py
touch ./app/templates/index.html
touch ./app/static/css/styles.css
touch ./app/static/js/scripts.js

cat > ./manage.py <<EOL
#!/usr/bin/env python
import os
import sys

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.base")
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)
EOL

# Make manage.py executable
chmod +x manage.py

# Config Files
cat > ./config/settings/base.py <<EOL
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
EOL

cat > ./config/urls.py <<EOL
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('app.urls')),
]
EOL

cat > ./config/asgi.py <<EOL
import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.base')
application = get_asgi_application()
EOL

cat > ./config/wsgi.py <<EOL
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.base')
application = get_wsgi_application()
EOL

# Add Celery Configuration
cat > ./config/celery.py <<EOL
from __future__ import absolute_import, unicode_literals
import os
from celery import Celery

# Set default Django settings module for Celery
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.base')

app = Celery('config')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Enable broker connection retry on startup for Celery 6.0+
app.conf.broker_connection_retry_on_startup = True

# Autodiscover tasks from installed apps
app.autodiscover_tasks()

@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
EOL

# Add Celery to the __init__.py file of config
cat >> ./config/__init__.py <<EOL
from __future__ import absolute_import, unicode_literals

# This will make sure the app is always imported when Django starts.
from .celery import app as celery_app

__all__ = ('celery_app',)
EOL

cat >> ./app/tasks/__init__.py <<EOL
from .example import log_message
EOL

# Add a sample logging task
cat > ./app/tasks/example.py <<EOL
import logging
from celery import shared_task

logger = logging.getLogger(__name__)

@shared_task
def log_message(message):
    logger.info(f'Celery Worker Log: {message}')
    return f'Logged: {message}'

EOL

# App Files
cat > ./app/apps.py <<EOL
from django.apps import AppConfig
from elasticsearch_dsl import connections
import os

class AppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'app'

    def ready(self):
        # Initialize Elasticsearch connection
        connections.create_connection(
            alias='default',
            hosts=[os.getenv('ELASTICSEARCH_HOST', 'http://elasticsearch:9200')]
        )
EOL

cat > ./app/urls.py <<EOL
from django.urls import path
from .views.index import index
from .views.healthcheck import HealthCheckView

urlpatterns = [
    path('', index, name='index'),
    path('healthcheck/', HealthCheckView.as_view(), name='healthcheck'),
]
EOL

cat > ./app/views/index.py <<EOL
from django.shortcuts import render

def index(request):
    return render(request, 'index.html')
EOL

cat > ./app/admin.py <<EOL
from django.contrib import admin
# Register your models here if needed.
EOL

# Template Files
cat > ./app/templates/index.html <<EOL
{% load static %}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World</title>
    <link rel="stylesheet" href="{% static 'css/styles.css' %}">
</head>
<body>
    <h1>Hello World</h1>
    <script src="{% static 'js/scripts.js' %}"></script>
</body>
</html>
EOL


# Static Files
cat > ./app/static/css/styles.css <<EOL
body {
    text-align: center;
}
h1 {
    color: #222222;
}
EOL

cat > ./app/static/js/scripts.js <<EOL
document.addEventListener('DOMContentLoaded', () => {
    console.log('Hello World: JavaScript Loaded!');
});
EOL

# Serializers
cat > ./app/serializers/api/healthcheck_serializer.py <<EOL
from rest_framework import serializers

class HealthCheckSerializer(serializers.Serializer):
    status = serializers.CharField()
    version = serializers.CharField()
    example_count = serializers.CharField()
    index_example_count = serializers.CharField()
EOL

# Views
cat > ./app/views/healthcheck.py <<EOL
from elasticsearch_dsl.connections import connections
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.renderers import JSONRenderer
from app.serializers.api.healthcheck_serializer import HealthCheckSerializer
from app.models.example import Example

class HealthCheckView(APIView):
    renderer_classes = [JSONRenderer]  # Ensure only JSON is returned

    def get(self, request, *args, **kwargs):
        # Get Elasticsearch default connection
        es_connection = connections.get_connection()
        index_example_count = es_connection.count(index="examples")["count"]

        data = {
            "status": "healthy",
            "version": "1.0.0",
            "example_count": Example.objects.count(),
            "index_example_count": index_example_count,
        }
        serializer = HealthCheckSerializer(data)
        return Response(serializer.data)
EOL

# Add __init__.py for models and migrations
cat > ./app/models/__init__.py <<EOL
from .example import Example

__all__ = ["Example"]
EOL

# Example model file
cat > ./app/models/example.py <<EOL
from django.db import models

class Example(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name
EOL

# Initial migration
cat > ./app/migrations/0001_initial.py <<EOL
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name='Example',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('description', models.TextField()),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
        ),
    ]
EOL

# Create the documents/__init__.py
cat > ./app/documents/__init__.py <<EOL
# Import ExampleDocument here for registration with Django Elasticsearch DSL
from .example_document import ExampleDocument
EOL

# ElasticSearch
cat > ./app/documents/example_document.py <<EOL
from django_elasticsearch_dsl import Document
from django_elasticsearch_dsl.registries import registry
from app.models.example import Example

@registry.register_document
class ExampleDocument(Document):
    class Index:
        # Name of the Elasticsearch index
        name = "examples"

        # Settings for the index
        settings = {
            "number_of_shards": 1,
            "number_of_replicas": 0
        }

    class Django:
        model = Example  # Model associated with this document

        # Fields of the model to be indexed in Elasticsearch
        fields = [
            "id",
            "name",
            "description",
            "created_at",
            "updated_at",
        ]
EOL

# Commands
cat > ./app/management/commands/reset_example_index.py <<EOL
from django.core.management.base import BaseCommand
from app.documents.example_document import ExampleDocument
from app.models.example import Example

class Command(BaseCommand):
    help = 'Reset Elasticsearch index for Example'

    def handle(self, *args, **kwargs):
        self.stdout.write('Deleting the Example index...')
        ExampleDocument._index.delete(ignore=[400, 404])
        self.stdout.write('Creating the Example index...')
        ExampleDocument.init()
        self.stdout.write('Indexing all Example records...')
        for example in Example.objects.all():
            ExampleDocument().update(example)
        self.stdout.write('Done resetting Example index.')
EOL

# requirements.txt
touch ./requirements.txt
cat > ./requirements.txt <<EOL
Django==5.1.4
psycopg2-binary==2.9.10
celery==5.4.0
redis==5.2.1
django-celery-beat==2.7.0
django-celery-results==2.5.1
django-elasticsearch-dsl==8.0
elasticsearch-dsl==8.17.0
djangorestframework==3.15.2
EOL


echo "Project structure created successfully in the current directory!"
