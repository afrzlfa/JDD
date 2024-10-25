#!/bin/bash

docker build -t openresty-modsec .
docker run -d -p 8090:80 openresty-modsec
