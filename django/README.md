# Python/Django Server
This project is a python/django server setup demonstrating a RESTful API implementation, including databases, models, caching, and workers.

## Commands

- Build: `docker-compose build`
- Start: `docker-compose up`
- Check: `docker-compose ps`
- Stop: `docker-compose down`
- Clean: `docker system prune -f`
- Remove ES: `docker volume rm django_elasticsearch`
- Remove PG: `docker volume rm django_postgres`
- Celery: `docker-compose run --rm web celery -A config worker --loglevel=info'
- Migrate: `docker-compose exec web python manage.py migrate`
- Index: `docker-compose exec web python manage.py reset_example_index`
- Console: `docker-compose exec web python manage.py shell`

## Rebuild project

```shell
docker-compose down
docker system prune -f
docker volume rm django_elasticsearch
docker volume rm django_postgres
docker-compose up --build

# In another terminal
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py search_index --populate
```

## Instances
You can access the running server at: `http://127.0.0.1:8000`

## Celery Workers
The base project comes with an example worker which can be run with:

```python
from app.tasks.example import log_message
log_message.delay("Hello from Celery!")
```

## Database and Migrations
The following commands allow management of the database via migrations

- `docker-compose exec web python manage.py migrate` - migrate
- `docker-compose exec web python manage.py makemigrations` - create migrations based on model changes
- `docker-compose exec web python manage.py migrate <app_name> <migration_name>` - roll back to specific migration
  - Example: `docker-compose exec web python manage.py migrate app 0001`
- `docker-compose exec web python manage.py migrate <app_name> zero` - roll back all migrations
- `docker-compose exec web python manage.py showmigrations` - show migration status
- `docker-compose exec web python manage.py check` - check for migration errors

### Creating Models
The base project comes with an example model which can be created as follows

```python
from app.models.example import Example

# Create and save a record
example = Example.objects.create(
    name="Full Field Example",
    description="This record contains all fields from the migration."
)
```

## ElasticSearch
The following confirms ElasticSearch is up and running

```shell
curl -X GET 'http://localhost:9200/examples/_search?pretty=true'

# Example Search
curl -X GET 'http://localhost:9200/examples/_search?pretty=true' -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "description": "record"
    }
  }
}'
```

Additionally, our ES middleware gives us the following command to populate the entire index.

```shell
docker-compose exec web python manage.py search_index --rebuild
docker-compose exec web python manage.py search_index --populate
```

## Initial Setup
I left this set of code in the project to show the creation of the entire python project from scratch. The following command to run the script generated my entire project base to match a scale-ready application base.

```bash
./setup_django_project.sh
```

To delete everything the script generated run the following commands:

```bash
rm -rf app
rm -rf config
rm manage.py
rm requirements.txt
```
