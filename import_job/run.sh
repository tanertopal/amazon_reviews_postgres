#!/bin/sh
# wait-for-postgres.sh

set -e

# cd into directory in which this shell script resides
cd $(dirname "$0")

docker build -q -t import_job .
docker run -it --rm --net=host -v $(pwd)/datasets:/datasets import_job /scripts/import.sh
docker run -it --rm --net=host -v $(pwd)/datasets:/datasets import_job /scripts/creater_authors_view.sh