#!/bin/bash

set -e

# cd into directory in which this shell script resides
cd $(dirname "$0")

docker-compose down
