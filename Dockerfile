FROM pasarguard/panel:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    nginx \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /entrypoint.sh

ENV ALLOWED_ORIGINS=* \
    ENABLE_RECORDING_NODES_STATS=True

ENTRYPOINT ["/entrypoint.sh"]
