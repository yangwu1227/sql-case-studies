# SQL Case Studies

[Documenting SQL case studies](https://yangwu1227.github.io/sql-case-studies/) from Danny Ma's [8 Week SQL Challenge](https://8weeksqlchallenge.com/) for learning and practice purposes.

## Option 1: Docker, PostgreSQL and SQLPad 

Install [docker](https://docs.docker.com/get-docker/) and [docker compose](https://docs.docker.com/compose/install/):

```bash
$ docker compose up
```

SQLPad can accessed at [http://localhost:3000](http://localhost:3000) or the port specified in the `compose.yml` file.

Stop and remove the containers with:

```bash
$ docker compose down
```

## Option 2: Python, Amazon Athena, and Jupyter Notebook

### Virtual Environment

The project manager used in this project is [uv](https://docs.astral.sh/uv/):

```bash
$ uv sync --frozen
```

### Amazon Athena

The [Athena](https://yangwu1227.github.io/sql-case-studies/athena_client/#src.athena.Athena) class can be used to interact with Amazon Athena. To use this class, the principal whose credentials are used to access the AWS services must have the necessary permissions for [Athena](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonAthenaFullAccess.html) plus [S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-policy-language-overview.html) if a non-default bucket is used to store the [query results](https://docs.aws.amazon.com/athena/latest/ug/querying.html#query-results-specify-location) (see below for more details).

The needed permissions can be encapsulated in a [boto3 session](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/session.html) instance and passed as the first argument to the constructor of the `Athena` class. The [create_session](https://yangwu1227.github.io/sql-case-studies/utils/#src.utils.create_session) utility function can be used to create the session instance.

#### S3 Bucket

The `data` parquet files for the case studies must be stored in an S3 bucket. All DDL queires are stored in the `sql` directory under each case study directory. **These must be adjusted to point to the correct S3 urls**. The data files can be uploaded to an S3 bucket using the [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) or the console.

```bash
# Create a bucket
$ aws s3api create-bucket --bucket sql-case-studies --profile profile-name
# Upload all data files to the bucket
$ aws s3 cp data/ s3://sql-case-studies/ --recursive --profile profile-name 
```

Optionally, query results can configured to be stored in a non-default (i.e., `aws-athena-query-results-accountid-region`) s3 bucket. The query result S3 url can be stored as an environment variable, e.g. `ATHENA_S3_OUTPUT=s3://bucket-name/path/to/output/`, which can then be passed as the `s3_output` argument to the `Athena` class constructor. The client creates the default bucket if the `s3_output` argument is not provided.

```python
import os 
s3_output = os.getenv('ATHENA_S3_OUTPUT', '')
```

### Jupyter Notebook

Each case study folder contains a `notebooks` directory containing Jupyter notebooks that can be used to run SQL queries.
