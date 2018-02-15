# postgresql-service

## Installing postgresql-service
```Bash
cd /cloudtrust
#Get the repo
git clone ssh://git@git.elcanet.local:7999/cloudtrust/postgresql-service.git
cd postgresql-service

#install systemd unit file
install -v -o root -g root -m 644  deploy/etc/systemd/system/cloudtrust-postgresql@.service /etc/systemd/system/cloudtrust-postgresql@.service

mkdir build_context
cp cloudtrust-postgresql.dockerfile build_context/
cd build_context

#Build the dockerfile for DEV environment
docker build --build-arg environment=DEV -t cloudtrust-postgresql:f27 -t cloudtrust-postgresql -f cloudtrust-postgresql.dockerfile .

#create container 1
docker create -p 5432:5432 --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name postgresql cloudtrust-postgresql

systemctl daemon-reload
#start container DEV1
systemctl start cloudtrust-postgresql@1
```
