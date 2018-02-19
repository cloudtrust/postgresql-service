# postgresql-service

## Installing postgresql-service
```Bash
cd /cloudtrust
#Get the repo
git clone git@github:cloudtrust/postgresql-service.git
cd postgresql-service

#install systemd unit file
install -v -o root -g root -m 644  deploy/etc/systemd/system/cloudtrust-postgresql@.service /etc/systemd/system/cloudtrust-postgresql@.service

mkdir build_context
cp cloudtrust-postgresql.dockerfile build_context/
cd build_context

#Build the dockerfile 
docker build --build-arg postgresql_service_git_tag=${GIT_TAG} -t cloudtrust-postgresql:${GIT_TAG} -f cloudtrust-postgresql.dockerfile .

docker build --build-arg environment=${ENVIRONMENT} --build-arg config_repository=${CONFIG_REPO} --build-arg branch=${BRANCH} -t cloudtrust-postgresql -f cloudtrust-postgresql-config.dockerfile .

#create container 1
docker run -d -p 5432:5432 --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name postgresql cloudtrust-postgresql
```
