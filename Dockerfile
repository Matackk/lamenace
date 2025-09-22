# Python 3.12 slim image
FROM python:3.12-slim

WORKDIR /app

# System deps (optional but useful)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl ca-certificates tini && \
    rm -rf /var/lib/apt/lists/*

# Copy app files
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY bot.py ./
# seed pickle (will be copied to /data at runtime if not present there)
COPY bot_state.pickle ./

# Optional banner if you add it to the repo
# COPY start_banner.jpg ./

# Entrypoint: ensure /data has a seed pickle, then run bot
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/sh", "-lc", "[ -f /data/bot_state.pickle ] || cp -n /app/bot_state.pickle /data/bot_state.pickle; python bot.py"]
