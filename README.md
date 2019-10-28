# pgdump-aws-lambda
based off of [jameshy/pgdump-aws-lambda](https://github.com/jameshy/pgdump-aws-lambda)

# Development

This repo has a companion Docker image that makes it easier to develop and test the lambda locally with the peace of mind that will work on AWS lambda service. It also allows you to create a bundle to be uploaded to AWS lambda service.

### Pre-requirements:

- Have Docker installed on your machine (for more instructions follow: [https://docs.docker.com/docker-for-mac/install/](https://docs.docker.com/docker-for-mac/install/))
- Create a environment variables file on the root of the project named `.env.local` and populated using `.env` as a template.

## Run the function locally

    $ docker-compose build
    $ EVENT='{"PGDATABASE":"<database>","PGUSER":"<user>","PGPASSWORD":"<password>","PGHOST":"<host>","S3_BUCKET":"<s3_bucket>","ROOT":"<s3_root_path>","EXCLUDE_TABLES": ["table_1", "table_2"]}'
    $ docker-compose run app index.handler $EVENT
**NOTE:** `EXCLUDE_TABLES` is optional.
## Upgrade (or downgrade) the version of PostgreSQL

As of 25 Oct 2019, it is set to use PostgreSQL 11.4. If you need to upgrade it follow these steps:

1. Change the `PG_VERSION` and `postgres_folder` values on `docker-compose.yml`
2. Change the folder location (`PGDUMP_PATH`) under `lib/config.js`
3. Run `docker-compose build`

# Deploy Process

1. Run the builder container (this step assumes you have already ran `docker-compose build`)

        $ docker-compose run builder

2. Deploy the `[pgdump-aws-lambda.zip](http://pgdump-aws-lambda.zip)` that is located under `dist` on the desired lambda function.
    1. Through the AWS console navigate to the lambda function > click the upload button and select the .zip file described above > click save
    2. More automated processes will come shortly
