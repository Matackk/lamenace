# Dockerfile — robust persistence & clean runtime
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl tini \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source
COPY bot.py ./
# Seed an initial pickle (will be copied to /data at runtime if not present)
COPY bot_state.pickle ./

ENV PYTHONUNBUFFERED=1 \
    PORT=8080 \
    KEEPALIVE=1 \
    PERSIST_PATH=/data/bot_state.pickle

# Prepare data dir
RUN mkdir -p /data

ENTRYPOINT ["/usr/bin/tini", "--"]

# At start: if /data/bot_state.pickle missing, copy the seeded one; then launch
CMD ["/bin/sh","-lc","[ -f /data/bot_state.pickle ] || cp -n /app/bot_state.pickle /data/bot_state.pickle; python bot.py"]
