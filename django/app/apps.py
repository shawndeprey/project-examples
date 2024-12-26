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
