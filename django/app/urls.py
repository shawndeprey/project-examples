from django.urls import path
from .views.index import index
from .views.healthcheck import HealthCheckView

urlpatterns = [
    path('', index, name='index'),
    path('healthcheck/', HealthCheckView.as_view(), name='healthcheck'),
]
