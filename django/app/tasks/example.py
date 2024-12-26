import logging
from celery import shared_task

logger = logging.getLogger(__name__)

@shared_task
def log_message(message):
    logger.info(f'Celery Worker Log: {message}')
    return f'Logged: {message}'

