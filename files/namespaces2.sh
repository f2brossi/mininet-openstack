#!/bin/sh

# Connect mido to root namespaces so it can access the NSDB cluster
ip link add m1-br0 type veth peer name br0-m1
ip link set m1-br0 netns m1
brctl addif br0 br0-m1
# Prepare m1
ip netns add m1
ip link set br0-m1 up
ip netns exec m1 ip link set m1-br0 up
ip netns exec m1 ip addr add 10.0.0.3/8 dev m1-br0
ip netns exec m1 ip route add default via 10.0.0.1
# Run midolman
ip netns exec m1 /usr/share/midolman/midolman-start&
#ip netns exec m1 sysctl net.ipv4.ip_forward=1
# Connect one host to m1 to route with midolman
ip netns add h3
ip link add m1-h3 type veth peer name h3-m1
ip link set m1-h3 netns m1
ip netns exec m1 ip link set m1-h3 up
ip link set h3-m1 netns h3
ip netns exec h3 ip link set lo up
ip netns exec h3 ip link set h3-m1 up
ip netns exec h3 ip addr add 192.168.0.4/16 dev h3-m1
ip netns exec h3 ip route add default via 192.168.0.1
# Connect one host to m1 to route with midolman
ip netns add h4
ip link add m1-h4 type veth peer name h4-m1
ip link set m1-h4 netns m1
ip netns exec m1 ip link set m1-h4 up
ip link set h4-m1 netns h4
ip netns exec h4 ip link set lo up
ip netns exec h4 ip link set h4-m1 up
ip netns exec h4 ip addr add 192.168.0.5/16 dev h4-m1
ip netns exec h4 ip route add default via 192.168.0.1



