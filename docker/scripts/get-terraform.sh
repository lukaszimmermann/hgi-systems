#!/bin/bash

set -euf -o pipefail

# Create temporary directory for building
export TMPDIR=$(mktemp -d)

# Setup go environment in tmpdir
echo "setting up temporary go environment in $TMPDIR"
export GOPATH="${TMPDIR}/go"
export PATH="${GOPATH}/bin:$PATH"
mkdir -p "$GOPATH/src" "$GOPATH/bin"
chmod -R 777 "$GOPATH"
cd ${GOPATH}

echo "getting terraform source"
mkdir -p $GOPATH/src/github.com/hashicorp
cd $GOPATH/src/github.com/hashicorp
git clone https://github.com/hashicorp/terraform
cd terraform
git checkout v0.11.2

echo "building terraform"
export XC_ARCH="amd64"
export XC_OS="linux"
/bin/bash scripts/build.sh || (echo "failed to build terraform"; exit 1)
cp ${GOPATH}/bin/terraform /usr/local/bin/

echo "building terraform-provider-infoblox"
mkdir -p $GOPATH/src/github.com/prudhvitella
cd $GOPATH/src/github.com/prudhvitella
git clone https://github.com/wtsi-hgi/terraform-provider-infoblox.git
cd terraform-provider-infoblox
git checkout hgi-integration
make bin
cp ${GOPATH}/bin/terraform-provider-infoblox /usr/local/bin/

echo "removing $TMPDIR"
cd
rm -rf ${TMPDIR}

echo "setting up terraform plugins"
echo "providers {
  infoblox = \"/usr/local/bin/terraform-provider-infoblox\"
}" > ~/.terraformrc
