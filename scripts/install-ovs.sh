#!/usr/bin/env bash
#
# Installs Open vSwitch on Debian based operating systems
# and configures br0 with ports for testing.
#
# Author: William Gonzalez
# Email: will@wgz.sh

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

set -euo pipefail

get_packages() {
  packages=(
    openvswitch-switch
    openvswitch-common
  )

  for i in "${packages[@]}"; do
    apt-get install "$i" -y
  done
}

# We want to test that ovs is running, and if br0 exists.

set_ports() {
  ports=(1 2 3 4 5)

  if ip link show br0 | grep "br0"; then
    echo "br0 exists already"

    for i in "${ports[@]}"; do
      ip link add p"$i" type dummy
      ip link set p"$i" up
      ovs-vsctl add-port br0 p"$i" -- set Interface p"$i" ofport_request="$i"
      ovs-ofctl mod-port br0 p"$i" up

      echo "$i has been created"
      sleep 1
    done
  else
    echo "br0 does not exist"

    for i in "${ports[@]}"; do
      ip link add p"$i" type dummy
      ip link set p"$i" up
      ovs-vsctl add-br br0 -- set Bridge br0 fail-mode=secure
      ovs-vsctl add-port br0 p"$i" -- set Interface p"$i" ofport_request="$i"
      ovs-ofctl mod-port br0 p"$i" up

      echo "$i has been created"
      sleep 1
    done
  fi
}

get_packages
set_ports
