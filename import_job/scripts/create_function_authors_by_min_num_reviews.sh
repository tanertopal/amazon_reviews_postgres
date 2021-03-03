#!/bin/bash

set -e

# cd into directory in which this shell script resides
cd $(dirname "$0")

exec() {
    echo "Query: $1"
    PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -d dataset -c "$1"
}

exec "
    CREATE OR REPLACE FUNCTION authors_by_min_num_reviews(min_num_reviews bigint)
    RETURNS TABLE (
        id BIGINT,
        rid text,
        num_reviews BIGINT
    ) AS \$$
    BEGIN
        RETURN QUERY
        SELECT *
        FROM authors
        WHERE authors.num_reviews > min_num_reviews;
    END;
    \$$  LANGUAGE plpgsql;
"
