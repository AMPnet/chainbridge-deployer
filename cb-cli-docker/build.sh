#!/usr/bin/env bash
VERSION=1.0.0
docker build -t ampnet/cb-cli:latest -t ampnet/cb-cli:${VERSION} .
