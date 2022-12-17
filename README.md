# Introduction
This project provides Docker images to periodically back up a PostgreSQL database to AWS S3, Minio and to restore from the backup as needed.

# Usage
## Backup
```yaml
services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password

  backup:
    image: shynfard/pgbackups3:1.0
    environment:
      SCHEDULE: '@weekly'     # optional
      BACKUP_KEEP_DAYS: 7     # optional
      PASSPHRASE: passphrase  # optional
      S3_REGION: region
      S3_ACCESS_KEY_ID: key
      S3_SECRET_ACCESS_KEY: secret
      S3_BUCKET: my-bucket
      S3_PREFIX: backup
      POSTGRES_HOST: postgres
      POSTGRES_DATABASE: dbname
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
```

- Images are tagged by the major PostgreSQL version they support: `10`, `11`, `12`, `13`, or `14`.
- The `SCHEDULE` variable determines backup frequency. See go-cron schedules documentation [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules). Omit to run the backup immediately and then exit.
- If `PASSPHRASE` is provided, the backup will be encrypted using GPG.
- Run `docker exec <container name> sh backup.sh` to trigger a backup ad-hoc
- Use `BACKUP_KEEP_DAYS` to set time for how long you want to keep backup.

## Restore
> **WARNING:** DATA LOSS! All database objects will be dropped and re-created.
### ... from latest backup
```sh
docker exec <container name> sh restore.sh
```
> **NOTE:** If your bucket has more than a 1000 files, the latest may not be restored -- only one S3 `ls` command is used
### ... from specific backup
```sh
docker exec <container name> sh restore.sh <timestamp>
```

# Development
## Build the image locally
`ALPINE_VERSION` determines Postgres version compatibility. See [`build-and-push-images.yml`](.github/workflows/build-and-push-images.yml) for the latest mapping.
```sh
DOCKER_BUILDKIT=1 docker build --build-arg ALPINE_VERSION=3.14 .
```
## Run a simple test environment with Docker Compose
```sh
cp template.env .env
# fill out your secrets/params in .env
docker compose up -d
```

# Acknowledgements
This project is a fork and re-structuring of [eeshugerman/postgres-backup-s3](https://github.com/eeshugerman/postgres-backup-s3) for better docker file. 
