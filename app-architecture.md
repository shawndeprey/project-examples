# Post It! App Architecture
This document contains the architecture/ideation in general terms for the apps contained within this repo. This high level architecture is meant to be a blueprint for every app undeneath so that any `server` project can serve any `client` project. I've also laid out this architecture in much the same format in which I would normally architect a system in order to demonstrate my skillset.

# App Description
Post It! Is a simple example app which allows users to create Posts which are represented as Postit Notes. These Posts will show in reverse chronological order on the base app page and should render as if they were semi-randomly placed postit notes. Each post should include the date it was post, who posted it, a title, and a body of content. Each Post should be limited to a number of text which can fit on a general Postit note. If a #hashtag is used in the postit, the last 5 tags should be displayed on the top of the primary app page and denoted as "Recent Tags".

Each user should have a settings page which simply contains a user form to allow them to change their account data. Each user should additionally have a username which will be used on the sign in page. Sign in should consist of either a username or email, as we as a password. This page should also contain a link to create account. Since this is a same application, we should avoid requiring a functioning email service, so feel free to ignore flows which require sending emails such as account verification or password reset flows. Finally, on the create account flow, create a basic user form component which allows a user to create their account, and then update their account on their authenticated settings page.

# Models

## User
This model comes standard in django apps, so below are all the required fields for this app to function if implemented in other frameworks.

- first_name (max_length=150, blank=True)
- last_name (max_length=150, blank=True)
- email
- username (max_length=150, unique=True)
- password (max_length=128)
- last_login

## Post

```python
class Post(models.Model):
    title = models.CharField(max_length=20)
    content = models.TextField(max_length=150)
    created_at = models.DateTimeField(auto_now=True)
    updated_at = models.DateTimeField(auto_now=True)
```

# Cache

## Recent Tags
We'll need a redis cache to store the 5 most recent tags from posts. This script is just an example of how we should store/manage the recent tags as implemented in `python`.

```python
import redis
namespace = "rescent_tags"
redis_client = redis.Redis(host='localhost', port=6379, db=0)
tags = ["#python", "#django", "#redis", "#coding", "#webdev"]
redis_client.delete(namespace) # Clear previous tags
redis_client.rpush(namespace, *tags) # Push new tag set
# Retrieve rescent_tags
trending_tags = redis_client.lrange(namespace, 0, -1)
trending_tags = [tag.decode('utf-8') for tag in trending_tags]

print(trending_tags)
```

## Elasticsearch

### Post
We'll need to implement indexing for our post model.

Controllers