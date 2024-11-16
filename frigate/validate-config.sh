#!/usr/bin/env bash

docker run                                \
  -v $(pwd)/config.yml:/config/config.yml \
  --workdir /opt/frigate                  \
  --entrypoint python3                    \
  ghcr.io/blakeblackshear/frigate:stable  \
  -u -m frigate                           \
  --validate-config
