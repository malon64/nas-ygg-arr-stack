#!/bin/sh
set -eu

cd /srv/docker/arr-apps
exec /usr/bin/docker compose up -d
