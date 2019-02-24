# Docker image for Suricata

This repository contains a Dockerfile that builds a Docker image for Suricata using a
[Docker multi-stage build](https://docs.docker.com/develop/develop-images/multistage-build/)
so that no build dependencies (like compilers) remain in the final image.

Building the image:
```
docker build -t suricata .
```
