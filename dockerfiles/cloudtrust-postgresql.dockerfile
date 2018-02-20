FROM cloudtrust-baseimage:f27

ARG postgresql_service_git_tag
ARG config_env
ARG config_git_tag
ARG config_repo

# Install Postgresql and other required packages
RUN dnf -y install postgresql-server postgresql-contrib findutils sudo monit git && \
    dnf clean all

# Get the repositories
WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/postgresql-service.git && \
    git clone ${config_repo} ./config

WORKDIR /cloudtrust/postgresql-service
RUN git checkout ${postgresql_service_git_tag}

WORKDIR /cloudtrust/config
RUN git checkout ${config_git_tag}

WORKDIR /cloudtrust/config
RUN install -v -m0755 -o root -g root deploy/${config_env}/etc/systemd/system/postgresql_init_keycloak.service /etc/systemd/system/postgresql_init_keycloak.service && \
    install -v -m0755 -o root -g root deploy/${config_env}/etc/systemd/system/postgresql_init_sentry.service /etc/systemd/system/postgresql_init_sentry.service && \
    install -v -m0640 -o postgres -g postgres deploy/${config_env}/var/lib/pgsql/postgres.pwd /var/lib/pgsql/postgres.pwd


# Init Postgresql
RUN sudo -u postgres initdb --pgdata="/var/lib/pgsql/data"  --pwfile=/var/lib/pgsql/postgres.pwd

WORKDIR /cloudtrust/postgresql-service
RUN install -v -m0644 deploy/common/etc/security/limits.d/* /etc/security/limits.d/ && \
    install -v -m0644 deploy/common/etc/monit.d/* /etc/monit.d/ && \
    install -v -m0644 deploy/common/var/lib/pgsql/data/* /var/lib/pgsql/data/ && \
    mkdir -p /var/lib/pgsql/data/pg_log && \
    chown postgres:postgres -R /var/lib/pgsql

RUN systemctl enable postgresql.service && \
    systemctl enable postgresql_init_sentry.service && \
    systemctl enable postgresql_init_keycloak.service && \
    systemctl enable monit.service

VOLUME ["/var/lib/pgsql"]

EXPOSE 5432
