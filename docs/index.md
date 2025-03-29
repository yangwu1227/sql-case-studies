# SQL Case Studies

[Documenting SQL case studies](https://yangwu1227.github.io/sql-case-studies/) from Danny Ma's [8 Week SQL Challenge](https://8weeksqlchallenge.com/) for learning and practice purposes.

## Option 1: Docker, PostgreSQL and SQLPad

Install [docker](https://docs.docker.com/get-docker/) and [docker compose](https://docs.docker.com/compose/install/):

```bash
docker compose up
```

SQLPad can accessed at [http://localhost:3000](http://localhost:3000) or the port specified in the [compose.yml](https://github.com/yangwu1227/sql-case-studies/blob/main/compose.yml) file.

Stop and remove the containers with:

```bash
docker compose down
```

## Option 2: Python, Amazon Athena, and Jupyter Notebook

### Virtual Environment

The project manager used in this project is [uv](https://docs.astral.sh/uv/):

```bash
uv sync --frozen --all-groups
```

### Amazon Athena

The [Athena](https://yangwu1227.github.io/sql-case-studies/athena_client/#src.athena.Athena) class can be used to interact with Amazon Athena. To use this client, the AWS principal (e.g., an IAM role or IAM user) used must have the necessary permissions for [Athena](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonAthenaFullAccess.html).

Customized [S3](https://docs.aws.amazon.com/athena/latest/ug/s3-permissions.html) permissions are needed if a **non-default** bucket is to be used to store the [query results](https://docs.aws.amazon.com/athena/latest/ug/querying.html#query-results-specify-location) (see below for more details).

The required permissions can be encapsulated in a [boto3 session](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/session.html) instance and passed as the first argument to the constructor of the `Athena` client. The [create_session](https://yangwu1227.github.io/sql-case-studies/utils/#src.utils.create_session) utility function can be used to create the session instance. The parameters are:

* `profile_name`: The AWS credentials profile name to use.

* `role_arn`: The IAM role ARN to assume. If provided, the `profile_name` must have the `sts:AssumeRole` permission.

* `duration_seconds`: The duration, in seconds, for which the temporary credentials are valid. If [role-chaining](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html#iam-term-role-chaining) occurs, the maximum duration is 1 hour.

```python
import boto3
from src.utils import create_session

boto3_session = create_session(
    profile_name="aws-profile-name",
    role_arn=os.getenv("ATHENA_IAM_ROLE_ARN"), 
)
```

### S3 Bucket

The [data](https://github.com/yangwu1227/sql-case-studies/tree/main/data) parquet files for the case studies must be stored in an S3 bucket. All DDL queries are stored in the `sql` directory under each case study directory. **These must be adjusted to point to the correct S3 uris**. The data files can be uploaded to an S3 bucket using the [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) or the console.

```bash
# Create a bucket
$ aws s3api create-bucket --bucket sql-case-studies --profile profile-name
# Upload all data files to the bucket
$ aws s3 cp data/ s3://sql-case-studies/ --recursive --profile profile-name 
```

Optionally, query results can be configured to be stored in a custom S3 bucket, instead of the default bucket (i.e., `aws-athena-query-results-accountid-region`).

The query result S3 uri can be stored as an environment variable, e.g. `ATHENA_S3_OUTPUT=s3://bucket-name/path/to/output/`, which can then be passed as the `s3_output` argument to the `Athena` class constructor. The client creates the default bucket if the `s3_output` argument is not provided.

```python
import os 
from src.athena import Athena
from src.utils import create_session

boto3_session = create_session(
    profile_name="aws-profile-name",
    role_arn=os.getenv("ATHENA_IAM_ROLE_ARN"), 
)
s3_output = os.getenv('ATHENA_S3_OUTPUT', '')

athena = Athena(boto3_session=boto3_session, s3_output=s3_output)
```

### Jupyter Notebook

Each case study folder contains a `notebooks` directory containing Jupyter notebooks that can be used to run SQL queries.
