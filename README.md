# cfjump
Jumpbox Docker image with all required tools to operate and install Cloud Foundry. It works with different workflows, but focuses primarily on [Enaml](http://enaml.pezapp.io/).

It has been tested only on an Ubuntu Server 16.04 (Xenial) 64-bit Docker VM. Your mileage on other systems may vary. 

v0.4 includes:

- Ubuntu:xenial official base image
- Several Linux troubleshooting tools, from `dig` and `iPerf`, to `nmap` and `tcpdump`.
- `bosh-init` (latest)
- [BOSH](http://bosh.io/) CLI (latest)
- [uaac](https://docs.cloudfoundry.org/adminguide/uaa-user-management.html) CLI (latest)
- `cf` CLI (latest)
- Golang (1.7.1)
- [Concourse](http://concourse.ci/) `fly` CLI (latest)
- [Vault](https://www.vaultproject.io/) (latest)
- [Terraform](https://www.terraform.io/) (0.7.3)
- `safe` CLI, [an alternative Vault CLI](https://github.com/starkandwayne/safe) (latest)
- [certstrap](https://github.com/square/certstrap) (latest)
- [Spiff](https://github.com/cloudfoundry-incubator/spiff) (latest)
- [Spruce](http://spruce.cf/) (latest)
- [Genesis](https://github.com/starkandwayne/genesis) (latest)
- OpenStack CLI (latest)
- [Photon Controller](https://github.com/vmware/photon-controller) CLI (latest)
- [Enaml](http://enaml.pezapp.io/) (latest). All cloudconfigs and all plugins available.

For Enaml, since it's in very active development, the `$HOME/bin/update_enaml.sh $ENAML` is there to dynamically update and register the latest versions on demand. The $ENAML variable is set to `/opt/enaml`.

## Building
You can just get this image from Docker Hub by:

```
docker pull ramxx/cfjump:latest
```

Or if you prefer to build it yourself:

```
git clone https://github.com/RamXX/cfjump
cd cfjump
docker build -t ramxx/cfjump:latest -t ramxx/cfjump:v0.4 .
docker push ramxx/cfjump
```

## Running
First, make sure you can run instances as a regular unprivileged user. This container will create an internal user with uid and gid of 1000, same as the default in Ubuntu, which makes easier to share folders.

The included `cfj` script make the operation of virtual jumpboxes easy. I suggest you copy it to your $PATH and use it directly. The operation is:

- `cfj list` to list the running containers.
- `cfj <name>` to either create or enter a container.
- `cfj kill <name>` to delete a running container. The associated shared volume 
won't be deleted. That needs to be done manually if desired.

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

## Contributing
Please submit pull requests with any correction or improvement you want to do. I hope this is useful to other folks.
