#!/usr/bin/env bash

apt update \
    && apt install -y ca-certificates wget net-tools gnupg;

mkdir -p /etc/apt/keyrings && wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/keyrings/as-repository.asc

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/as-repository.asc] http://as-repository.openvpn.net/as/debian noble main">/etc/apt/sources.list.d/openvpn-as-repo.list

apt update && apt -y install openvpn-as
