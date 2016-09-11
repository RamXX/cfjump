# cfjump
Jumpbox Docker image with all required tools to operate and install Cloud Foundry. It works with different workflows, but focuses primarily on [Enaml](http://enaml.pezapp.io/).

v0.1 includes:

- Ubuntu:xenial official base image
- Several Linux troubleshooting tools, from `dig` to `iPerf`.
- Golang (1.7.1)
- [Concourse](http://concourse.ci/) `fly` CLI (latest)
- `cf` CLI (latest)
- `bosh-init` (0.0.96)
- [Vault](https://www.vaultproject.io/) (0.6.1)
- [Terraform](https://www.terraform.io/) (0.7.3)
- `safe` CLI, [an alternative Vault CLI](https://github.com/starkandwayne/safe) (latest)
- [BOSH](http://bosh.io/) CLI (latest)
- [uaac](https://docs.cloudfoundry.org/adminguide/uaa-user-management.html) CLI (latest)
- [certstrap](https://github.com/square/certstrap) (latest)
- [Spiff](https://github.com/cloudfoundry-incubator/spiff) (latest)
- [Spruce](http://spruce.cf/) (latest)

For [Enaml](http://enaml.pezapp.io/), since it's in very active development, the `$HOME/bin/update_enaml.sh` is there to download and register the latest versions. Check the Dockerfile to see the locations and actions.

## Building
You can just get this image from Docker Hub by:

```
docker pull ramxx/cfjump
```

Or if you prefer to build it yourself:

```
git clone
cd 
docker build -t ramxx/cfjump:latest -t ramxx/cfjump:v0.1 .
docker push ramxx/cfjump
```
## Running
To run a new instance:

```
mkdir shared_vol
docker run --name="Jumpbox1" -it -v $(pwd)/shared_vol:/var/host \
ramxx/cfjump /bin/bash
```
In this example, `shared_vol` will be shared with the host. Important files, like the BOSH session state and others should be placed here for backup purposes.

## Contributing
Please sumit pull requests with any correction or improvement you want to do. I hope this is useful to other folks.
