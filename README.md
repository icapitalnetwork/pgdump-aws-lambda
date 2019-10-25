# pgdump-aws-lambda
based off of [jameshy/pgdump-aws-lambda](https://github.com/jameshy/pgdump-aws-lambda)

# Overview

An AWS Lambda function that runs pg_dump and streams the output to s3.

It can be configured to run periodically using CloudWatch events.

## Quick start

1. Create an AWS lambda function:
    - Runtime: Node.js 10.16.3
    - Configuration -> Advanced Settings
        - Timeout = 5 minutes
        - Select a VPC and security group (must be suitable for connecting to the target database server)
2. Create a CloudWatch rule:
    - Event Source: Fixed rate of 1 hour
    - Targets: Lambda Function (the one created in step #1)
    - Configure input -> Constant (JSON text) and paste your config, e.g.:
    ```json
    {
        "PGDATABASE": "oxandcart",
        "PGUSER": "staging",
        "PGPASSWORD": "uBXKFecSKu7hyNu4",
        "PGHOST": "database.com",
        "S3_BUCKET" : "my-db-backups",
        "ROOT": "hourly-backups"
    }
    ```

Note: you can test the lambda function using the "Test" button and providing config like above.

**AWS lambda has a 5 minute maximum execution time for lambda functions, so your backup must take less time that that.**

## Development
To build the dev environment create a `.env.local` with the appropriate values, use `.env` as a template.
1. build the image
    ```shell script
    $ docker-compose build
    ```
2. Run the image
    ```shell script
    $ EVENT=$(echo '<json>' | jq -c)
    $ docker-compose run app index.handler $EVENT
    ```
3. Build zip for deployment
    ```shell script
    $ docker-compose run builder
    ```
    A file called `pgdump-aws-lambda.zip` should have appeared under `dist/`.
## File Naming

This function will store your backup with the following s3 key:

s3://${S3_BUCKET}${ROOT}/YYYY-MM-DD/YYYY-MM-DD@HH-mm-ss.backup

## PostgreSQL version compatibility

This script uses the pg_dump utility from PostgreSQL 11.4.

It should be able to dump older versions of PostgreSQL. I will try to keep the included  binaries in sync with the latest from postgresql.org, but PR or message me if there is a newer PostgreSQL binary available.

## Encryption

You can pass the config option 'ENCRYPTION_PASSWORD' and the backup will be encrypted using aes-256-ctr algorithm.

Example config:
```json
{
    "PGDATABASE": "dbname",
    "PGUSER": "postgres",
    "PGPASSWORD": "password",
    "PGHOST": "localhost",
    "S3_BUCKET" : "my-db-backups",
    "ENCRYPTION_PASSWORD": "my-secret-password"
}
```

To decrypt these dumps, use the command:
`openssl aes-256-ctr -d -in ./encrypted-db.backup  -nosalt -out unencrypted.backup`
