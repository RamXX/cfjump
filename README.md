# cfjump
Jumpbox Docker image with all required tools to install and operate Cloud Foundry from the command line. It works with different installation workflows, and includes several tools to work with Ops Manager and other Pivotal-specific components. It also includes some IaaS-specific CLI tools for AWS, GCP, Azure, VMware Photon Controller and OpenStack as well as a config generator for VMware NSX.

It has been tested on Ubuntu Server 16.04 (Xenial) 64-bit, Photon OS Docker host VM, and Docker for Mac. Your mileage on other systems may vary.

**Warning:** This is a 2.23 GB image. It was designed to give you the user experience of a real jumpbox VM, not to be necessarily used in Concourse or other automated tools.

v0.33 includes:

##### Linux
- Ubuntu:xenial official base image (large, but guarantees a "workstation-like" environment)
- Several Linux troubleshooting tools, from `dig` and `iPerf`, to `nmap` and `tcpdump`.

##### Cloud Foundry tools
- [`bosh`](https://github.com/cloudfoundry/bosh-cli) (2.0.28) - BOSH 2.0 Golang CLI. GA release. The binary is also linked to `bosh2` for pre-existing scripts. The Ruby BOSH CLI has been deprecated and it's no longer included here.
- [uaac](https://docs.cloudfoundry.org/adminguide/uaa-user-management.html) CLI (latest)
- `cf` CLI (latest)
- [Concourse](http://concourse.ci/) `fly` CLI (latest)
- [asg-creator](https://github.com/cloudfoundry-incubator/asg-creator) (latest) A cleaner way to create and manage ASGs.
- [omg-transform](https://github.com/enaml-ops/omg-transform) (latest). An enaml based tool that allows you to perform transformations on bosh manifests.
- [CredHub CLI](https://github.com/cloudfoundry-incubator/credhub-cli) (1.2.0) a command line interface to interact with CredHub servers.
- [`cf mysql` CLI plugin](https://github.com/andreasf/cf-mysql-plugin) (1.4) makes it easy to connect the mysql command line client to any MySQL-compatible database used by Cloud Foundry apps.
- [`goblob`](https://github.com/pivotal-cf/goblob) (latest) a tool for migrating Cloud Foundry blobs from one blobstore to another. Presently it only supports migrating from an NFS blobstore to an S3-compatible one.

##### Pivotal-specific
- [cfops](https://github.com/pivotalservices/cfops) (latest) automation based on the supported way to back up Pivotal Cloud Foundry
- [PivNet CLI](https://github.com/pivotal-cf/go-pivnet) `pivnet` (experimental, early Alpha) CLI (latest)
- [cf-mgmt](https://github.com/pivotalservices/cf-mgmt) (latest) Go automation for managing orgs, spaces that can be driven from concourse pipeline and git-managed metadata.
- [bosh-bootloader](https://github.com/cloudfoundry/bosh-bootloader) (latest) Command line utility for standing up a CloudFoundry or Concourse installation on an IAAS of your choice.
- [om](https://github.com/pivotal-cf/om) (latest) Small sharp tool for deploying products to ops-manager.
- [magnet](https://github.com/pivotalservices/magnet) (latest) Better AZ distribution for vSphere.
- [autopilot](https://github.com/xchapter7x/autopilot) (latest) cf plugin for hands-off, zero downtime application deploys.
- [cliaas](https://github.com/pivotal-cf/cliaas) (latest) wraps multiple IaaS-specific libraries to perform some IaaS-agnostic functions. Presently it only supports upgrading a Pivotal Cloud Foundry Operations Manager VM.
- [cloudfoundry-top-plugin](https://github.com/ECSTeam/cloudfoundry-top-plugin) (latest) cf interactive plugin for showing live statistics of the targeted Cloud Foundry foundation. By ECS team.
- [cf-service-connect](https://github.com/18F/cf-service-connect)(1.1) makes it easy to connect to your databases or other Cloud Foundry service instances from your local machine.
- [tile-generator](http://docs.pivotal.io/tiledev/tile-generator.html) (latest) Tool that helps tile authors develop, package, test, and deploy services and other add-ons to Pivotal Cloud Foundry (PCF).

##### IaaS tools
- [Terraform](https://www.terraform.io/) (0.9.11)
- OpenStack CLI (latest), both, legacy `nova`, `cinder`, `keystone`, etc commands as well as the newer `openstack` integrated CLI.
- [Microsoft Azure CLI](https://github.com/Azure/azure-xplat-cli) (latest)
- [Google Compute Cloud CLI](https://cloud.google.com/sdk/downloads#linux) (latest)
- [AWS CLI](https://aws.amazon.com/cli/) (latest)
- [Photon Controller](https://github.com/vmware/photon-controller) (latest) CLI 

##### Network virtualization
- [`nsx-edge-gen`](https://github.com/cf-platform-eng/nsx-edge-gen) (latest) Generates NSX logical switches, Edge service gateways and LBs against the VMware NSX 6.3 API version.

##### Other useful tools
- [Vault](https://www.vaultproject.io/) (latest)
- `safe` CLI, [an alternative Vault CLI](https://github.com/starkandwayne/safe) (latest)
- [Spiff](https://github.com/cloudfoundry-incubator/spiff) (1.0.8)
- [Spruce](http://spruce.cf/) (latest)
- [Genesis](https://github.com/starkandwayne/genesis) (latest)
- [BUCC](https://github.com/starkandwayne/bucc) (latest) The fastest way to get a BUCC (BOSH, UAA Credhub and Concourse) stack
- [kubectl](https://kubernetes.io/docs/user-guide/prereqs/) Kubernetes CLI. Useful for [Kubo](https://pivotal.io/kubo).

##### Extras

If you need this extra apps, you must first install the Golang environment with the `add_go.sh` command and then run `add_extras.sh`. This is because these tools 
publish only source code and not binaries, and the decoupling was necessary to reduce the size of the Docker image.

- [`cfdot`](https://github.com/cloudfoundry/cfdot)  CF Diego Operator Toolkit, a CLI tool designed to interact with Diego components.
- [certstrap](https://github.com/square/certstrap) (latest)
- [Deployadactyl](https://github.com/compozed/deployadactyl) (latest). Go library for deploying applications to multiple Cloud Foundry instances.

## Running

**STOP:** Cfjump is not meant to be ran directly with `docker run`, but rather to be used with the `cfj` companion CLI. You **must** follow the steps below, otherwise you will see all sorts of permissions problems.

Cfjump runs instances as a regular unprivileged user. This container will create an internal user with uid and gid of 9024, so you will need to provide your `sudo` password to create a directory with this uid that can be mounted in the container.

Step 1: 
```
wget https://raw.githubusercontent.com/RamXX/cfjump/master/cfj
chmod +x cfj
sudo mv cfj /usr/local/bin
docker pull ramxx/cfjump
```
The usage of the `cfj` CLI is as follows:

- `cfj list` (or simply `cfj` with no arguments) to list the running containers.
- `cfj <name>` to either create or enter a container.
- `cfj kill <name>` to delete a running container. **The associated shared volume
won't be deleted**. That needs to be done manually if desired. You can also specify `cfj kill all`, which will destroy all running (or stopped) jumpbox containers.

You can use different jumpbox instances for different sessions, users, environments, etc, as long as you use different shared folders.

## `cf` CLI plugins
Plugins are installed automatically upon the creation of the virtual jumpbox with the `cfj` command, so the first run will take a few seconds longer than future runs.

## No-go
The Golang environment was installed by default in previous versions to make easier to add new Golang tools, but this increased the size of the image substantially.
For this reason, Go is now decoupled from the image itself. It can be installed with the simple command `add_go.sh` in `/usr/local/bin`. By default, it will install
version 1.8.1, but it can be easily adjusted to other versions as needed. See also the note under "Extras" above.

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

Note that you still need the `cfj` script from this repo. You can either `git clone` the repo or download the script directly.

## Limitations
Every instance of a container can only be used by a single user at the time. If another user attempts to join the same container while being used, all screen I/O will be duplicated in each screen.

It may be possible to use an `sshd` daemon to support multiple sessions, but that's outside the scope of this work.

Additionally, `man` pages are not installed in this image to decrease its size. Typically, man pages can be accessed on the Docker host itself or easily found online.

# Note for Enaml
For Enaml, since it's in very active development, you may want to use the `update_enaml.sh` script to dynamically update and register the latest versions on demand. Of course, this will only download Enaml for the current instance of the container. In order to use Enaml, **you must run** the updater at least once. No default binaries are included.

The $ENAML variable is the location where the Enaml packages will be downloaded to, and it's mandatory. In the container, it is set to `/opt/enaml` by default.

## Contributing
Please submit pull requests with any correction or improvement you want to do. I hope this is useful to others.
