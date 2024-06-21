FROM python:3.10-slim

WORKDIR /app
COPY . .

# Necessary for reflex init 
RUN apt-get update && apt-get install -y \
    gcc python3-dev unzip curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

# Deploy templates and prepare app
RUN reflex init

# Export static copy of frontend to /app/.web/_static
RUN reflex export --frontend-only --no-zip

# Needed until Reflex properly passes SIGTERM on backend.
STOPSIGNAL SIGKILL

# Always apply migrations before starting the backend.
CMD [ -d alembic ] && reflex db migrate; reflex run --env prod
