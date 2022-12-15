#!/bin/bash
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64" \
  -o "/usr/local/lib/docker/cli-plugins/docker-compose"
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose