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
