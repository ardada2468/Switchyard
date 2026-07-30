FROM python:3.12-slim
RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir pytest
WORKDIR /code
RUN printf 'def greet():\n    return "world"\n' > app.py
RUN git init -q && git config user.email "t@t" && git config user.name "t" && git add -A && git commit -q -m init
