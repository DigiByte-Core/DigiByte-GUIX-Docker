FROM debian:unstable

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    bzip2 \
    ca-certificates \
    curl \
    git \
    guix \
    make

ARG builder_count=32
ARG branch=develop

# Build Environment Setup
# https://guix.gnu.org/manual/en/html_node/Build-Environment-Setup.html#Build-Environment-Setup

RUN addgroup guixbuild

RUN for i in $(seq -w 1 ${builder_count}); do    \
      useradd -g guixbuild -G guixbuild          \
              -d /var/empty -s $(which nologin)  \
              -c "Guix build user ${i}" --system \
              "guixbuilder${i}" ;                \
    done

CMD guix-daemon \
      --build-users-group=guixbuild   \
      --substitute-urls="https://ci.guix.gnu.org"

RUN git clone https://github.com/DigiByte-Core/digibyte.git -b $branch /digibyte

WORKDIR /digibyte