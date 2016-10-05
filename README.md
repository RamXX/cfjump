# cfjump
Jumpbox Docker image with all required tools to install and operate Cloud Foundry from the command line. It works with different workflows, including [Enaml](http://enaml.pezapp.io/) and others, and includes several tools to work with OpsManager and other Pivotal-specific components. It also includes some IaaS-specific CLI tools for AWS, GCP, Azure, VMware Photon Controller and OpenStack.

It has been tested only on an Ubuntu Server 16.04 (Xenial) 64-bit Docker host VM. Your mileage on other systems may vary.

v0.9 includes:

- Ubuntu:xenial official base image
- Several Linux troubleshooting tools, from `dig` and `iPerf`, to `nmap` and `tcpdump`.
- `bosh-init` (latest)
- [BOSH](http://bosh.io/) CLI (latest)
- [uaac](https://docs.cloudfoundry.org/adminguide/uaa-user-management.html) CLI (latest)
- `cf` CLI (latest)
- Golang (1.7.1)
- [Concourse](http://concourse.ci/) `fly` CLI (latest)
- [CFOps](https://github.com/pivotalservices/cfops) (latest) automation based on the supported way to back up Pivotal Cloud Foundry
- [PivNet CLI](https://github.com/pivotal-cf/go-pivnet) `pivnet` (experimental, early Alpha) CLI (latest)
- [Vault](https://www.vaultproject.io/) (latest)
- [Terraform](https://www.terraform.io/) (0.7.4)
- `safe` CLI, [an alternative Vault CLI](https://github.com/starkandwayne/safe) (latest)
- [certstrap](https://github.com/square/certstrap) (latest)
- [Spiff](https://github.com/cloudfoundry-incubator/spiff) (latest)
- [Spruce](http://spruce.cf/) (latest)
- [Genesis](https://github.com/starkandwayne/genesis) (latest)
- OpenStack CLI (latest), both, legacy `nova`, `cinder`, `keystone`, etc commands as well as the newer `openstack` integrated CLI.
- [Microsoft Azure CLI](https://github.com/Azure/azure-xplat-cli) (latest)
- [Google Compute Cloud CLI](https://cloud.google.com/sdk/downloads#linux) (latest)
- [AWS CLI](https://aws.amazon.com/cli/) (latest)
- [Photon Controller](https://github.com/vmware/photon-controller) CLI (latest)
- [OpsMan-cli](https://github.com/datianshi/opsman) (CLI to interact with OpsManager).
- [cf-mgmt](https://github.com/pivotalservices/cf-mgmt) (latest) Go automation for managing orgs, spaces that can be driven from concourse pipeline and git-managed metadata.
- [asg-creator](https://github.com/cloudfoundry-incubator/asg-creator) (latest) A cleaner way to create and manage ASGs.
- [Enaml](http://enaml.pezapp.io/) (update program only).

For Enaml, since it's in very active development, you need to use the `$HOME/bin/update_enaml.sh` to dynamically update and register the latest versions on demand. Of course, this will only download Enaml for the current instance of the container.

The $ENAML variable is the location where the Enaml packages will be downloaded to, and it's mandatory. In the container, it is set to `/opt/enaml` by default.

## Running
First, make sure you can run instances as a regular unprivileged user. This container will create an internal user with uid and gid of 1000, same as the default in Ubuntu, which makes easier to share folders with the host.

The included `cfj` script make the operation of virtual jumpboxes easy. Copy it to a directory in your $PATH and use it to interact with the virtual jumpboxes. The operation is:

- `cfj list` (or simply `cfj` with no arguments) to list the running containers.
- `cfj <name>` to either create or enter a container.
- `cfj kill <name>` to delete a running container. **The associated shared volume
won't be deleted**. That needs to be done manually if desired. You can also specify `cfj kill all`, which will destroy all running (or stopped) jumpbox containers.

You can use different jumpbox instances for different sessions, users, environments, etc, as long as you use different shared folders.

## Building
You can just get this image from Docker Hub by running:

```
docker pull ramxx/cfjump:latest
```

Or if you prefer to build it yourself:

```
git clone https://github.com/RamXX/cfjump
cd cfjump
docker build -t ramxx/cfjump:latest -t ramxx/cfjump:v0.9 .
docker push ramxx/cfjump
```

## Limitations
Every instance of a container can only be used by a single user at the time. If another user attempts to join the same container while being used, all screen I/O will be duplicated in each screen.

It may be possible to use an `sshd` daemon to support multiple sessions, but that's outside the scope of this work.

Additionally, `man` pages are not installed in this image to decrease its size. Typically, man pages can be accessed on the Docker host itself or easily found online.

## Contributing
Please submit pull requests with any correction or improvement you want to do. I hope this is useful to others.
