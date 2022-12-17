FROM ubuntu:22.04
ARG TARGETARCH


ADD src/ACCC4CF8.asc /etc/apt/trusted.gpg.d/pgdg.asc
RUN     tee /etc/apt/trusted.gpg.d/pgdg.asc  &>/dev/null

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update

RUN apt-get update
RUN apt-get install -y postgresql-client
RUN apt-get update && apt-get install -y \
    gnupg \
    python3 \
    python3-pip \
    curl 

RUN pip3 install awscli

RUN curl -Lo go-cron.tar.gz https://github.com/ivoronin/go-cron/releases/download/v0.0.5/go-cron_0.0.5_linux_${TARGETARCH}.tar.gz 
RUN tar xvf go-cron.tar.gz
RUN rm go-cron.tar.gz
RUN mv go-cron /usr/local/bin/go-cron
RUN chmod u+x /usr/local/bin/go-cron

RUN apt-get purge -y curl 

ENV POSTGRES_DATABASE ''
ENV POSTGRES_HOST ''
ENV POSTGRES_PORT 5432
ENV POSTGRES_USER ''
ENV POSTGRES_PASSWORD ''
ENV PGDUMP_EXTRA_OPTS ''
ENV S3_ACCESS_KEY_ID ''
ENV S3_SECRET_ACCESS_KEY ''
ENV S3_BUCKET ''
ENV S3_REGION 'us-west-1'
ENV S3_PATH 'backup'
ENV S3_ENDPOINT ''
ENV S3_S3V4 'no'
ENV SCHEDULE ''
ENV PASSPHRASE ''
ENV BACKUP_KEEP_DAYS ''

ADD src/run.sh run.sh
ADD src/env.sh env.sh
ADD src/backup.sh backup.sh
ADD src/restore.sh restore.sh

CMD ["sh", "run.sh"]