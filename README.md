# Postgresql

This repository contains our postgresql dockerfile.


## Building the dockerfile

We recommend running the build tasks via our deployment procedure, but in case you want to build it yourself, there are many build arguments to pass. You can learn about them by reading the dockerfile.

## Running postgresql

Depending on the config repo, containers could expect some names to be reachable. Refer to the specifics of the configuration repo.

An example run command should look like

```Bash
#Run the container
docker run --rm -it --net=ct_bridge --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name postgresql -p 8080:80 cloudtrust-postgresql
```
