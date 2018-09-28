FROM cloudtrust-baseimage:f27

ARG postgresql_service_git_tag
ARG postgresql_tools_git_tag
ARG config_git_tag
ARG config_repo

ARG postgresql-server_version=9.6.10-1.fc27
ARG postgresql-contrib_version=9.6.10-1.fc27
ARG python3-pip_version=9.0.3-2.fc27

# Install Postgresql and other required packages
RUN dnf update -y && \
    dnf -y install postgresql-server-$postgresql-server_version postgresql-contrib-$postgresql-contrib_version findutils monit git python3-pip-$python3-pip_version && \
    dnf clean all

# Get the repositories
WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/postgresql-service.git && \
    echo hello && \
    git clone git@github.com:cloudtrust/postgresql-tools.git && \
    git clone ${config_repo} ./config

WORKDIR /cloudtrust/postgresql-tools
RUN git checkout ${postgresql_tools_git_tag}

WORKDIR /cloudtrust/postgresql-tools
RUN pyvenv . && \
    . bin/activate && \
    pip install -r ./requirements.txt

WORKDIR /cloudtrust/postgresql-service
RUN git checkout ${postgresql_service_git_tag}

WORKDIR /cloudtrust/config
RUN git checkout ${config_git_tag}

WORKDIR /cloudtrust/config
RUN install -d -v -m0755 /cloudtrust/postgresql-scripts && \
    install -v -m0750 -o postgres -g postgres deploy/cloudtrust/postgresql-scripts/* /cloudtrust/postgresql-scripts/ && \
    install -v -m0640 -o postgres -g postgres deploy/var/lib/pgsql/postgres.pwd /var/lib/pgsql/postgres.pwd


# Init Postgresql
USER postgres
RUN initdb --pgdata="/var/lib/pgsql/data"  --pwfile=/var/lib/pgsql/postgres.pwd

USER root
WORKDIR /cloudtrust/postgresql-service
RUN install -v -m0644 deploy/etc/security/limits.d/* /etc/security/limits.d/ && \
    install -v -m0644 deploy/etc/monit.d/* /etc/monit.d/ && \
    install -v -m0644 deploy/var/lib/pgsql/data/* /var/lib/pgsql/data/ && \
    mkdir -p /var/lib/pgsql/data/pg_log && \
    chown postgres:postgres -R /var/lib/pgsql

RUN systemctl enable postgresql.service && \
    systemctl enable monit.service

VOLUME ["/var/lib/pgsql"]

EXPOSE 5432
