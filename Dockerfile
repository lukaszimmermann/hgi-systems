FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# Install Go/Packer prerequisite and openstack packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         apt-utils \
         software-properties-common \
    && apt-get install -y --no-install-recommends \
         bash \
         build-essential \
         curl \
         g++ \
         gcc \
         git \
         libc6-dev \
         libffi-dev \
         libssl-dev \
         make \
         openssh-client \
         pkg-config \
         python-openstackclient \
         python3-dev \
         python3-openstackclient \
         python3-pip \
         python3-setuptools \
         python3-wheel \
    && rm -rf /var/lib/apt/lists/*

# Build Go
ENV GOLANG_VERSION 1.7.4
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 47fda42e46b4c3ec93fa5d4d4cc6a748aa3f9411a2a2b7e08e3a6d80d753ec8b
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

# Build packer
ENV PACKER_DEV=1
RUN go get github.com/mitchellh/gox
RUN cd $GOPATH/src/github.com/mitchellh && \
    git clone https://github.com/mitchellh/packer.git && \
    cd packer && \
    git checkout v0.12.3
WORKDIR $GOPATH/src/github.com/mitchellh/packer
RUN /bin/bash scripts/build.sh

# Install glancecp
RUN cd /tmp \
    && git clone https://github.com/wtsi-hgi/openstack-tools.git \
    && cd openstack-tools \
    && python3 setup.py install

# Install ansible and friends using pip3
RUN pip3 install --no-cache-dir git+https://github.com/ansible/ansible.git@7f352207 \
    && pip3 install --no-cache-dir shade==1.16.0 \
    && pip3 install --no-cache-dir git+https://github.com/wtsi-hgi/gitlab-build-variables-manager.git@v1.0.0 \
    && pip3 install --no-cache-dir boto==2.46.1

# Set workdir and entrypoint
WORKDIR /tmp
ENTRYPOINT []
