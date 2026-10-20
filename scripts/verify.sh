#!/usr/bin/env bash
set -u

cd "$(dirname "$0")/.." || exit 1
mkdir -p evidence

echo "=== GDA Docker Project Verification ==="

if docker ps --filter "name=^/gda-docker-web$" \
  --format '{{.Names}}' | grep -qx 'gda-docker-web'; then
  echo "PASS: Container is running"
else
  echo "FAIL: Container is not running"
  exit 1
fi

if docker image inspect gda-docker-web:v1 >/dev/null 2>&1; then
  echo "PASS: Docker image exists"
else
  echo "FAIL: Docker image not found"
  exit 1
fi

HTTP_STATUS=$(curl -sS -o /tmp/gda-verify.html \
  -w '%{http_code}' --max-time 10 http://localhost:8081/) || {
  echo "FAIL: HTTP request failed"
  exit 1
}

echo "HTTP Status: $HTTP_STATUS"

if [ "$HTTP_STATUS" != "200" ]; then
  echo "FAIL: Expected HTTP 200"
  exit 1
fi

if grep -q 'Gondal Digital Agency' /tmp/gda-verify.html; then
  echo "PASS: GDA website content found"
else
  echo "FAIL: Expected website content not found"
  exit 1
fi

docker ps --filter "name=^/gda-docker-web$" \
  > evidence/container-status.txt
docker logs --tail 50 gda-docker-web \
  > evidence/container-logs.txt 2>&1
printf 'HTTP Status: %s\n' "$HTTP_STATUS" \
  > evidence/http-test.txt

echo "PASS: All verification checks completed"
echo "Evidence saved in evidence/"
