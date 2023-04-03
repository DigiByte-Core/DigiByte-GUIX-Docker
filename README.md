# Build DigiByte Core using GUIX and Docker

## Prerequisites
- Ubuntu or Mac without Silicon Chip
- RAM: 8 GB
- Free disk space: 60 GB
- Github Account
- docker installed on your machine
- Ideally some knowledge on how build environments work

> **Warning**
> For this release you cannot use Macs with M1/M2 CPUs.
> Support will be added in a future release though!

## Install
Clone the repository using

```bash
https://github.com/DigiByte-Core/DigiByte-GUIX-Docker.git && cd DigiByte-GUIX-Docker
```

## Create a docker image
```bash
# Use the following command to build the docker image
DOCKER_BUILDKIT=1 docker build --pull --no-cache -t alpine-guix --build-arg branch=release/v8.22-rc1 - < Dockerfile
```

Note that the most recent changes are still in the branch `fix/functional-and-guix` so replace the branch build-arg with:

```bash
# Use the following command to build the docker image
DOCKER_BUILDKIT=1 docker build --pull --no-cache -t alpine-guix --build-arg branch=fix/functional-and-guix - < Dockerfile
```

## Run the docker image
Set the path of the location where YOU saved the Xcode12.2 SDK
```bash
export PATH_TO_SDK_TARBALL=/path/to/Xcode-12.2-12B45b-extracted-SDK-with-libcxx-headers.tar.gz
```

After you have created the image, run the following command:

```bash
docker run -it --name alpine-guix --privileged -v "$PATH_TO_SDK_TARBALL:/xcode.tar" alpine-guix
```

Make sure you configure your Docker to have at least 8 GB of memory ("Memory") and ~70 GB of space ("Disk image size").
The more cores and the more memory, the better. This screenshot illustrates adequate example settings for the compilation: 

<img width="1014" alt="Screenshot 2023-03-13 at 21 43 10" src="https://user-images.githubusercontent.com/934592/224827683-afa67e86-6c3b-4a6e-b95b-6d07179b0e12.png">

Open another shell and perform the following steps:

```bash
# This command will lead you straight into the `digibyte` directory in that container.
docker exec -ti alpine-guix /bin/bash
```

From there you have to unpack the tarball using the following commands:

```bash
mkdir -p depends/SDKs
tar -C depends/SDKs -xaf /xcode.tar
```

## Start the build process
From within the docker container, run:

```
# Specify which version you want to sign
export VERSION="8.22-rc1"

# Make sure you are on the correct branch
git checkout origin "v${VERSION}"

# Start the build process
./contrib/guix/guix-build
```


## Attesting the release

### Prerequisites
You need your `gpg` key ready for this to work. Install gpg on your hostsystem and make sure you generated a new key, for example:

```bash
# This command will guide you until you get your GPG key
gpg --generate-key
```

Next, you will have to export the gpg key and import it into the docker container.

So on your host use `docker cp -a $USER/.gnupg alpine-guix:/root/.gnupg` to copy your private keys into the docker container.

Second prerequisite: Fork the repo `https://github.com/DigiByte-Core/guix.sigs.git` to your personal github account.

> **Warning**
> DISCLAIMER: Generally I would advice the use of `gpg-agent` or mounting the required files into the docker container. However, we don't want this guide to explode in length. Advanced users can proceed with their favorite technique.

Once you copied the keys (you can ignore the errors about sockets not being supported), use the shell that's within your docker container to continue.

```bash
# Clone the repositories
git clone https://github.com/DigiByte-Core/guix.sigs.git /guix.sigs
git clone https://github.com/DigiByte-Core/digibyte-detached-sigs.git /digibyte-detached-sigs

# Replace `yoshijaeger` with your gpg name
export DGB_SIGNER="yoshijaeger"

# Set the path (no need to modify anything here if you cloned the repos as mentioned above)
export GUIX_SIGS_REPO="/guix.sigs" 

# This command will ask you to enter the passphrase that you used to generate the gpg keys
env GUIX_SIGS_REPO="$GUIX_SIGS_REPO" SIGNER="$DGB_SIGNER" ./contrib/guix/guix-attest
```

After running this command, you should now have a `noncodesigned.SHA256SUMS(.asc)` file located in `/guix.sigs/$VERSION/$DGB_SIGNER` (example: `/guix.sigs/yoshijaeger/8.22-rc1`). All you need to do is commiting those signatures:

Either copy the repo /guix.sigs to your host system and continue to work there, or you can create a temporary github access token and configure git directly in docker, like so:

```bash
git config --global user.email "your-github-emailaddress@host.com"
git config --global user.name "Your Name"

# Example: git remote add myrepo "https://github.com/SmartArray/guix.sigs.git"
git remote add myrepo "<git-url-to-your-forked-guix-sigs-repo>"
```

```bash
# Commit the signature
cd  /guix.sigs
git switch main
git pull
git checkout -b "${VERSION}-non-codesigned"
git add "$VERSION"
git commit -m "Add attestations by $SIGNER for $VERSION non-codesigned"
git push --set-upstream myrepo "${VERSION}-non-codesigned"
```

This will ask you for you access token that you can generate here:

https://github.com/settings/tokens

After entering the access token, your signature will be pushed to your repo! Just create a pull request and you are done!

Congrats! And thank you so much for helping us to sign the rc-1.

