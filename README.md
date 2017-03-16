# cfjump
Jumpbox Docker image with all required tools to install and operate Cloud Foundry from the command line. It works with different install workflows, and includes several tools to work with Ops Manager and other Pivotal-specific components. It also includes some IaaS-specific CLI tools for AWS, GCP, Azure, VMware Photon Controller and OpenStack.

It has been tested only on an Ubuntu Server 16.04 (Xenial) 64-bit Docker host VM. Your mileage on other systems may vary.

**Warning:** This is a large, 4.81GB image. It was designed to give you the user experience of a real jumpbox VM, not to be necessarily used in Concourse.

v0.19 includes:

##### Linux
- Ubuntu:xenial official base image (large, but guarantees a "workstation-like" environment)
- Several Linux troubleshooting tools, from `dig` and `iPerf`, to `nmap` and `tcpdump`.
- Golang (1.7.1)

##### Cloud Foundry tools
- `bosh-init` (latest)
- [BOSH](http://bosh.io/) Ruby BOSH CLI (latest) called by the command name `bosh`.
- [`bosh2`](https://github.com/cloudfoundry/bosh-cli) (latest) - New BOSH 2.0 Golang CLI. Binary called `bosh2` to avoid confusion with the Ruby CLI.
- [uaac](https://docs.cloudfoundry.org/adminguide/uaa-user-management.html) CLI (latest)
- `cf` CLI (latest)
- [Concourse](http://concourse.ci/) `fly` CLI (latest)
- [asg-creator](https://github.com/cloudfoundry-incubator/asg-creator) (latest) A cleaner way to create and manage ASGs.
- [Enaml](https://github.com/enaml-ops/omg-cli) (latest). Deploy Cloud Foundry without YAML.
- [omg-transform](https://github.com/enaml-ops/omg-transform) (latest). An enaml based tool that allows you to perform transformations on bosh manifests.
- [Deployadactyl](https://github.com/compozed/deployadactyl) (latest). Go library for deploying applications to multiple Cloud Foundry instances.
- [CredHub CLI](https://github.com/cloudfoundry-incubator/credhub-cli) (0.5.1)(pre-release) a command line interface to interact with CredHub servers.
- [`cf mysql` CLI plugin](https://github.com/andreasf/cf-mysql-plugin) (1.3.6) makes it easy to connect the mysql command line client to any MySQL-compatible database used by Cloud Foundry apps.

##### Pivotal-specific
- [cfops](https://github.com/pivotalservices/cfops) (latest) automation based on the supported way to back up Pivotal Cloud Foundry
- [PivNet CLI](https://github.com/pivotal-cf/go-pivnet) `pivnet` (experimental, early Alpha) CLI (latest)
- [cf-mgmt](https://github.com/pivotalservices/cf-mgmt) (latest) Go automation for managing orgs, spaces that can be driven from concourse pipeline and git-managed metadata.
- [bosh-bootloader](https://github.com/cloudfoundry/bosh-bootloader) Command line utility for standing up a CloudFoundry or Concourse installation on an IAAS of your choice.
- [om](https://github.com/pivotal-cf/om) Small sharp tool for deploying products to ops-manager.
- [magnet](https://github.com/pivotalservices/magnet) Better AZ distribution for vSphere.
- [autopilot](https://github.com/xchapter7x/autopilot) cf plugin for hands-off, zero downtime application deploys.
- [cliaas](https://github.com/pivotal-cf/cliaas) wraps multiple IaaS-specific libraries to perform some IaaS-agnostic functions. Presently it only supports upgrading a Pivotal Cloud Foundry Operations Manager VM.
- [cloudfoundry-top-plugin](https://github.com/ECSTeam/cloudfoundry-top-plugin) cf interactive plugin for showing live statistics of the targeted Cloud Foundry foundation. By ECS team.

##### IaaS tools
- [Terraform](https://www.terraform.io/) (0.7.4)
- OpenStack CLI (latest), both, legacy `nova`, `cinder`, `keystone`, etc commands as well as the newer `openstack` integrated CLI.
- [Microsoft Azure CLI](https://github.com/Azure/azure-xplat-cli) (latest)
- [Google Compute Cloud CLI](https://cloud.google.com/sdk/downloads#linux) (latest)
- [AWS CLI](https://aws.amazon.com/cli/) (latest)
- [Photon Controller](https://github.com/vmware/photon-controller) CLI (latest)

##### Other useful tools
- [Vault](https://www.vaultproject.io/) (latest)
- `safe` CLI, [an alternative Vault CLI](https://github.com/starkandwayne/safe) (latest)
- [certstrap](https://github.com/square/certstrap) (latest)
- [Spiff](https://github.com/cloudfoundry-incubator/spiff) (1.0.8)
- [Spruce](http://spruce.cf/) (latest)
- [Genesis](https://github.com/starkandwayne/genesis) (latest)
- [Hugo](http://gohugo.io/) (latest) Static site generator written in Go. Ideal for documentation projects.
- [kubectl](https://kubernetes.io/docs/user-guide/prereqs/) Kubernetes CLI. Useful for [Kubo](https://pivotal.io/kubo).




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
docker build -t ramxx/cfjump:latest .
```

## Limitations
Every instance of a container can only be used by a single user at the time. If another user attempts to join the same container while being used, all screen I/O will be duplicated in each screen.

It may be possible to use an `sshd` daemon to support multiple sessions, but that's outside the scope of this work.

Additionally, `man` pages are not installed in this image to decrease its size. Typically, man pages can be accessed on the Docker host itself or easily found online.

# Note for Enaml
For Enaml, since it's in very active development, you may want to use the `update_enaml.sh` script to dynamically update and register the latest versions on demand. Of course, this will only download Enaml for the current instance of the container. The latest image at the time of the build was included.

The $ENAML variable is the location where the Enaml packages will be downloaded to, and it's mandatory. In the container, it is set to `/opt/enaml` by default.

## Contributing
Please submit pull requests with any correction or improvement you want to do. I hope this is useful to others.
