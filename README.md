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

## File Naming

This function will store your backup with the following s3 key:

s3://${S3_BUCKET}${ROOT}/YYYY-MM-DD/YYYY-MM-DD@HH-mm-ss.backup

## PostgreSQL version compatibility

This script uses the pg_dump utility from PostgreSQL 11.2.

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

## Loading your own `pg_dump` binary
1. `docker run -v ~/<local-folder>:/home/user/<local-folder-name> -it amazonlinux /bin/bash`
2. Install the following packahes from `https://download.postgresql.org/pub/repos/yum/<version>/redhat/rhel-<version>-x86_64/`
    1. `postgresql11-libs.x86_64 0:11.2-1PGDG.rhel7`
    2. `postgresql11.x86_64 0:11.2-1PGDG.rhel7`
3. Copy `pg_dump` from `bin/pg_dump` to `/home/user/<local-folder-name>`
4. Copy `libpq.so.5` from `/usr/pgsql-11/lib/libpq.so.5` to `/home/user/<local-folder-name>`
5. Add both files to project
