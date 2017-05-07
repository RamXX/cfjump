#!/bin/bash
GOVERSION=1.8.1
wget -q -O - "https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz" \
    | sudo tar -C /usr/local -zx
sudo add-apt-repository -y ppa:masterminds/glide
sudo apt-get update && sudo apt-get -y --no-install-recommends install glide
go version
