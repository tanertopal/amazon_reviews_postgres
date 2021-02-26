#!/bin/bash

set -e

# cd into directory in which this shell script resides
cd $(dirname "$0")

# DATASET
# It is assumed that the dataset is available in the directory
# /datasets directory named data.json.gz and meta.json.gz
if [ ! -f /datasets/data.json ]; then
    echo "Gunzipping data.json.gz"
    pv /datasets/data.json.gz | gunzip > /datasets/data.json
fi

if [ ! -f /datasets/meta.json ]; then
    echo "Gunzipping meta.json.gz"
    pv /datasets/meta.json.gz | gunzip > /datasets/meta.json
fi

recreate_db() {
    echo "Delete (if exists) and recreate dataset database"
    PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -c "DROP DATABASE IF EXISTS dataset;"
    PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -c "CREATE DATABASE dataset;"
}

exec() {
    echo "Query: $1"
    PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -d dataset -c "$1"
} 

recreate_db

exec "CREATE TABLE data_json (values text);"
exec "CREATE TABLE meta_json (values text);"

echo "Insert data.json"
pv /datasets/data.json | sed -e 's/\\/\\\\/g' | exec "COPY data_json (values) FROM STDIN;"

echo "Insert meta.json"
pv /datasets/meta.json | sed -e 's/\\/\\\\/g' | exec "COPY meta_json (values) FROM STDIN;"

exec "ALTER TABLE data_json ALTER COLUMN VALUES type jsonb USING regexp_replace(values, '\\u0000', '', 'g')::JSON;"
exec "ALTER TABLE meta_json ALTER COLUMN VALUES type jsonb USING regexp_replace(values, '\\u0000', '', 'g')::JSON;"

exec "CREATE INDEX data_json_asin_idx ON data_json ((values->>'asin'));"
exec "CREATE INDEX data_json_reviewer_id_idx ON data_json ((values->>'reviewerID'));"
exec "CREATE INDEX meta_json_asin_idx ON meta_json ((values->>'asin'));"