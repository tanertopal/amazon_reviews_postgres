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

### SQL Functions

To optimize some queries a few materialized views and SQL functions are created.

**Get reviews by author ID:**

Id range with the book reviews dataset is from `1` to `15362619`.

```sql
SELECT * FROM reviews_by_author_id(1);
```

**WARNING:** The numerical author id / string reviewerID mapping is not stable and even with
the same base dataset you might end up with a different numerical id / reviewerID mapping
after recreating the database. They are stable between queries though.

**Get authors with min number of reviews:**

```sql
SELECT * FROM authors_by_min_num_reviews(10);
```
