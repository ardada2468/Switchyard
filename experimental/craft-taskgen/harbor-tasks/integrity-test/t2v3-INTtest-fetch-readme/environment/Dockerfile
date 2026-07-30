FROM python:3.12-slim
RUN apt-get update && apt-get install -y curl ca-certificates git \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir pytest
WORKDIR /code
RUN git init && git config user.email "agent@test" && git config user.name "Agent" \
    && touch .gitkeep && git add -A && git commit -m 'initial commit'
