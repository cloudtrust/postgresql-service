ARG postgresql_service_git_tag
FROM cloudtrust-postgresql:${postgresql_service_git_tag}

ARG environment
ARG branch
ARG config_repository

WORKDIR /cloudtrust

# Get config
RUN git clone ${config_repository} ./config && \
	cd ./config && \
    git checkout ${branch}

# Setup Customer http-router related config
############################################

WORKDIR /cloudtrust/config
RUN install -v -m0755 -o root -g root deploy/${environment}/etc/systemd/system/postgresql_init_keycloak.service /etc/systemd/system/postgresql_init_keycloak.service && \
    install -v -m0755 -o root -g root deploy/${environment}/etc/systemd/system/postgresql_init_sentry.service /etc/systemd/system/postgresql_init_sentry.service && \
    install -v -m0640 -o postgres -g postgres deploy/${environment}/var/lib/pgsql/postgres.pwd /cloudtrust/postgres.pwd


# Init Postgresql
RUN sudo -u postgres initdb --pgdata="/var/lib/pgsql/data"  --pwfile=/cloudtrust/postgres.pwd

WORKDIR /cloudtrust/postgresql-service
RUN install -v -m0644 deploy/common/var/lib/pgsql/data/* /var/lib/pgsql/data/ && \
    mkdir -p /var/lib/pgsql/data/pg_log && \
    chown postgres:postgres -R /var/lib/pgsql && \
    systemctl enable postgresql.service && \
    systemctl enable postgresql_init_sentry.service && \
    systemctl enable postgresql_init_keycloak.service

