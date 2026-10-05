FROM pasarguard/panel:latest

RUN apt-get update && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV ALLOWED_ORIGINS=* \
    ENABLE_RECORDING_NODES_STATS=True

ENTRYPOINT ["/entrypoint.sh"]
