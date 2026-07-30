FROM python:3.12-slim
RUN apt-get update && apt-get install -y git curl ca-certificates build-essential
# Clone celery at the pre-change commit (before retry unification)
RUN git clone https://github.com/celery/celery.git /code && cd /code && git checkout 99b0a897708f1a2188dff8b9f93fb0b8cdc6fe86
WORKDIR /code
# Install celery with SQLAlchemy support
RUN pip install -e '.[sqlalchemy]' 2>&1 | tail -5
# Install test dependencies
RUN pip install pytest pytest-timeout pytest-subtests PyYAML msgpack pydantic
# Verify installation
RUN python -c "import celery; import sqlalchemy; from celery.backends.database import DatabaseBackend; print('celery + sqlalchemy OK')"
# Reset git
RUN rm -rf .git && git init && git config user.email "agent@test" && git config user.name "Agent" && git add -A && git commit -m 'initial commit'
RUN mkdir -p /code/output
