#!/bin/bash

set -e

# cd into directory in which this shell script resides
cd $(dirname "$0")

exec() {
    echo "Query: $1"
    PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -d dataset -c "$1"
} 

exec "
  CREATE MATERIALIZED VIEW authors AS
      SELECT
          /* id and rid mapping is not stable and might change on each query */
          row_number() over () as id,
          rid,
          num_reviews
      FROM (
              SELECT
                  DISTINCT data_json.values ->> 'reviewerID' AS rid,
                  count(data_json.values ->> 'reviewerID') AS num_reviews
              FROM data_json
              GROUP BY rid
          ) sub;

  CREATE UNIQUE INDEX data_json_authors_id_idx ON authors (id);
  CREATE UNIQUE INDEX data_json_authors_rid_idx ON authors (rid);
"
