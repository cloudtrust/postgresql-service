FROM cloudtrust-baseimage:f27

ARG postgresql_service_git_tag
ARG environment

WORKDIR /cloudtrust

# Install Postgresql
RUN dnf -y install postgresql-server postgresql-contrib findutils sudo monit git && \
    git clone git@github.com:cloudtrust/postgresql-service.git
    cd postgresql-service && \
    git checkout ${postgresql_service_git_tag}


WORKDIR /cloudtrust/postgresql-service
# Init Postgresql
RUN sudo -u postgres initdb --pgdata="/var/lib/pgsql/data"  --pwfile=deploy/${environment}/postgres.pwd

# Configure Postgesql
RUN install -v -m0644 deploy/common/etc/security/limits.d/* /etc/security/limits.d/ && \
    install -v -m0644 deploy/common/var/lib/pgsql/data/* /var/lib/pgsql/data/ && \
    mkdir -p /var/lib/pgsql/data/pg_log && \
    chown postgres:postgres -R /var/lib/pgsql && \
# Install monit
    install -v -m0644 deploy/common/etc/monit.d/* /etc/monit.d/

# Enable Systemd units
RUN systemctl enable postgresql.service && \
    systemctl enable monit.service

VOLUME ["/var/lib/pgsql"]

EXPOSE 5432
