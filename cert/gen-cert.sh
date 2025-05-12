#!/bin/bash

set -e

openssl req -x509 -new -nodes -newkey rsa:4096 -keyout server.key -out server.crt -days 365 -subj "/CN=api.beatport.com" -extensions SAN -config <(cat << EOF
[req]
distinguished_name=req
[SAN]
subjectAltName=DNS:api.beatport.com
EOF
)
