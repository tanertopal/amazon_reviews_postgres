#!/bin/bash

set -e

# cd into directory in which this shell script resides
cd $(dirname "$0")

exec() {
    echo "Query: $1"
    PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -d dataset -c "$1"
} 

exec "
    CREATE OR REPLACE FUNCTION reviews_by_author_id(author_id bigint)
    RETURNS TABLE (
        id BIGINT,
        val JSONB
    ) AS $$
    BEGIN
        RETURN QUERY
        SELECT a.id, dj.values
        FROM authors a
        LEFT JOIN data_json dj
            ON a.rid = dj.values->>'reviewerID'
        WHERE a.id = author_id;
    END;
    $$  LANGUAGE plpgsql;
"
