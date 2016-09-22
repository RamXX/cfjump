# cfjump
Jumpbox Docker image with all required tools to operate and install Cloud Foundry. It works with different workflows, but focuses primarily on [Enaml](http://enaml.pezapp.io/).

It has been tested only on an Ubuntu Server 16.04 (Xenial) 64-bit Docker host VM. Your mileage on other systems may vary.

v0.7 includes:

- Ubuntu:xenial official base image
- Several Linux troubleshooting tools, from `dig` and `iPerf`, to `nmap` and `tcpdump`.
- `bosh-init` (latest)
- [BOSH](http://bosh.io/) CLI (latest)
- [uaac](https://docs.cloudfoundry.org/adminguide/uaa-user-management.html) CLI (latest)
- `cf` CLI (latest)
- Golang (1.7.1)
- [Concourse](http://concourse.ci/) `fly` CLI (latest)
- [PivNet CLI](https://github.com/pivotal-cf/go-pivnet) `pivnet` (experimental, early Alpha) CLI (latest)
- [Vault](https://www.vaultproject.io/) (latest)
- [Terraform](https://www.terraform.io/) (0.7.3)
- `safe` CLI, [an alternative Vault CLI](https://github.com/starkandwayne/safe) (latest)
- [certstrap](https://github.com/square/certstrap) (latest)
- [Spiff](https://github.com/cloudfoundry-incubator/spiff) (latest)
- [Spruce](http://spruce.cf/) (latest)
- [Genesis](https://github.com/starkandwayne/genesis) (latest)
- OpenStack CLI (latest)
- [Photon Controller](https://github.com/vmware/photon-controller) CLI (latest)
- [OpsMan-cli](https://github.com/datianshi/opsman) (CLI to interact with OpsManager).
- [Enaml](http://enaml.pezapp.io/) (update program only).

For Enaml, since it's in very active development, you need to use the `$HOME/bin/update_enaml.sh` to dynamically update and register the latest versions on demand. Of course, this will download Enaml only for the current instance of the container.

The $ENAML variable is the location where the Enaml packages will be downloaded to, and it's mandatory. In the container, it is set to `/opt/enaml` by default.

## Building
You can just get this image from Docker Hub by:

```
docker pull ramxx/cfjump:latest
```

Or if you prefer to build it yourself:

```
git clone https://github.com/RamXX/cfjump
cd cfjump
docker build -t ramxx/cfjump:latest -t ramxx/cfjump:v0.7 .
docker push ramxx/cfjump
```

## Running
First, make sure you can run instances as a regular unprivileged user. This container will create an internal user with uid and gid of 1000, same as the default in Ubuntu, which makes easier to share folders.

The included `cfj` script make the operation of virtual jumpboxes easy. I suggest you copy it to your $PATH and use it directly. The operation is:

- `cfj list` (or simply `cfj` with no arguments) to list the running containers.
- `cfj <name>` to either create or enter a container.
- `cfj kill <name>` to delete a running container. The associated shared volume
won't be deleted. That needs to be done manually if desired. You can also specify `cfj kill all`, which will destroy all running containers.

Without the script, you can manually run a brand new instance:

```
mkdir shared_vol && touch shared_vol/.touchfile
docker run --name="Jumpbox1" -it -v $(pwd)/shared_vol:/home/ops \
ramxx/cfjump /bin/bash
```

This container will map its $HOME to the `shared_vol` directory.
Important files, like the BOSH session state and others should be placed here.

If you exit that shell, the container will remain in stopped mode. In order to go back into the same container again, do this:

```
docker start -ai Jumpbox1
```
Which will put you in the same place as you were before. You can use different jumpbox instances for different sessions, users, environments, etc, as long as you use different shared folders.

## Limitations
Every instance of a container can be used by a single user at the time. If another user attempts to join the same container while being used, all I/O will be shared in the screen. This can be a positive thing from the security standpoint, since only one user can be connected at the time, but in some cases it may be useful to have a second session.

It may be possible to use an `sshd` daemon for that purpose, but that's outside the scope of this work.

Additionally, `man` pages are not installed in this image to decrease its size. Typically, man pages can be accessed on the Docker host itself or easily found online.

## Contributing
Please submit pull requests with any correction or improvement you want to do. I hope this is useful to other folks.
