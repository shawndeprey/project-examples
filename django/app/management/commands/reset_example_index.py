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
