#!/bin/bash

docker build -t openresty-modsec .
docker run -d -p 8090:80 --user 0:0 openresty-modsec
