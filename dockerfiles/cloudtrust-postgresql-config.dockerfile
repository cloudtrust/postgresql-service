FROM cloudtrust-postgresql:alpha-0.1

ARG environment
ARG branch
ARG config_repository

WORKDIR /cloudtrust

# Get config
RUN git clone ${config_repository} && \
	cd /cloudtrust/${config_repository} && \
    git checkout ${branch}

# Setup Customer http-router related config
############################################

WORKDIR /cloudtrust/${config_repository}
RUN install -v -m0755 -o root -g root deploy/${environment}/etc/systemd/system/postgresql_init_keycloak.service /etc/systemd/system/postgresql_init_keycloak.service && \
    install -v -m0755 -o root -g root deploy/${environment}/etc/systemd/system/postgresql_init_sentry.service /etc/systemd/system/postgresql_init_sentry.service && \
    systemctl enable postgresql_init_sentry.service && \
    systemctl enable postgresql_init_keycloak.service
