# Amazon review data served through PostgreSQL

## Setup

**CAUTION:** This is only tested wit Book reviews.

1. Download dataset from: http://deepyeti.ucsd.edu/jianmo/amazon/index.html
2. Put dataset and meta file into ./import_job/datasets directory named:
    * data.json.gz
    * meta.json.gz
3. Run `start.sh`
4. Run `./import_job/run.sh`
5. Check if import was successful at
    * http://localhost:8080/?pgsql=db&username=postgres&db=dataset
    * Username: postgres
    * Password: postgres

## How to query the data

We can consider each reviewer as a partition in our Federated Learning experiment. To get all partition IDs run:

```sql
SELECT DISTINCT data_json.values->>'reviewerID'
FROM data_json;
```

To get all reviews for a single reviewerID you might run

```sql
SELECT *
FROM data_json
WHERE data_json.values->>'reviewerID' = 'AGUJ97UTICV4W';
```
