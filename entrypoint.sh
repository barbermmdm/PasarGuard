#!/bin/sh
set -e

CERT_DIR=/var/lib/pasarguard/certs
CERT=$CERT_DIR/ssl_cert.pem
KEY=$CERT_DIR/ssl_key.pem

mkdir -p "$CERT_DIR"

if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
    echo ">> Creating SSL certificate..."

    openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
        -keyout "$KEY" \
        -out "$CERT" \
        -subj "/CN=panel" \
        2>/dev/null
fi

echo ">> Running database migration..."
python -m alembic upgrade head

echo ">> Generating temporary owner key..."
python pasarguard-cli.py generate-temp-key || true

export UVICORN_HOST=127.0.0.1
export UVICORN_PORT=8000
export UVICORN_SSL_CERTFILE="$CERT"
export UVICORN_SSL_KEYFILE="$KEY"
export UVICORN_SSL_CA_TYPE=private

echo ">> Starting PasarGuard..."

python main.py &

sleep 5

echo ">> Starting Nginx on port ${PORT:-8080}..."

sed -i "s/listen 0.0.0.0:8080/listen 0.0.0.0:${PORT:-8080}/" /etc/nginx/nginx.conf

exec nginx -g "daemon off;"
