# Build DigiByte Core using GUIX and Docker

## Prerequisites
Install docker on your machine.

## Install
Clone the repository using

```bash
https://github.com/DigiByte-Core/DigiByte-GUIX-Docker.git && cd DigiByte-GUIX-Docker
```

## Create a docker image
```bash
# Use the following command to build the docker image
DOCKER_BUILDKIT=1 docker build --pull --no-cache -t alpine-guix --build-arg branch=develop - < Dockerfile
```

Note that the most recent changes are still in the branch `fix/functional-and-guix` so replace the branch build-arg with:

```bash
# Use the following command to build the docker image
DOCKER_BUILDKIT=1 docker build --pull --no-cache -t alpine-guix --build-arg branch=fix/functional-and-guix - < Dockerfile
```

## Run the docker image
Open another shell and perform the following steps:

Set the path of the Xcode12.2 SDK
```bash
export PATH_TO_SDK_TARBALL=/path/to/Xcode-12.2-12B45b-extracted-SDK-with-libcxx-headers.tar.gz
```

After you have created the image, run the following command:

```bash
docker run -it --name alpine-guix --privileged -v "$PATH_TO_SDK_TARBALL:/xcode.tar" alpine-guix
```

This command will lead you straight into the `digibyte` directory in that container.

From there you have to unpack the tarball using the following commands:

```bash
mkdir -p depends/SDKs
tar -C depends/SDKs -xaf /xcode.tar
```

## Start the build process
From within the docker container, run:

```bash
./contrib/guix/guix-build
```
