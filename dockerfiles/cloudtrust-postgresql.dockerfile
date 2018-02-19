FROM cloudtrust-baseimage:f27

ARG postgresql_service_git_tag

WORKDIR /cloudtrust

# Install Postgresql
RUN dnf -y install postgresql-server postgresql-contrib findutils sudo monit git && \
    git clone git@github.com:cloudtrust/postgresql-service.git && \
    cd postgresql-service && \
    git checkout ${postgresql_service_git_tag}

WORKDIR /cloudtrust/postgresql-service

# Configure Postgesql
RUN install -v -m0644 deploy/common/etc/security/limits.d/* /etc/security/limits.d/ && \
# Install monit
    install -v -m0644 deploy/common/etc/monit.d/* /etc/monit.d/

# Enable Systemd units
RUN systemctl enable monit.service

VOLUME ["/var/lib/pgsql"]

EXPOSE 5432
