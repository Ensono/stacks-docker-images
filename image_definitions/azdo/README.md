# CICD images for TFS => VSTS => AzureDevops Services 2019 => AzureDevops Server

Since AZDO requires certain prerequisites for non glibc based OS like Alpine certain magic has to happen, such as:

- aws cliv2

It's fairly straight forward for compiled binaries in C/C++/Go like:

- terraform

- envsubst

- configmanager

## Build

example build and push

```bash
cd ./image_definitions/azdo
export VERSION=0.0.2
docker build -t $DOCKER_REPO/cicd-utils-azdo-tf:$VERSION -f terraform.Dockerfile .
```

## Push

```bash
docker push $DOCKER_REPO/cicd-utils-azdo-tf:$VERSION
```
