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
