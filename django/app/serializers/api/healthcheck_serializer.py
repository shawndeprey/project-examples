from rest_framework import serializers

class HealthCheckSerializer(serializers.Serializer):
    status = serializers.CharField()
    version = serializers.CharField()
    example_count = serializers.CharField()
    index_example_count = serializers.CharField()
