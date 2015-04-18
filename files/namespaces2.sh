#!/bin/sh

add_link () {
    # Pass edges and ips as arguments and add a veth pair
    # Add link between different namespaces (aka hosts to midos)
    # EDGE1 EDGE2 IP1/MASK GW1 IP2/MASK GW2
    # namespaces and edges must be equal and unique
    ip link add $1-$2 type veth peer name $2-$1
    # Set namespace
    ip link set $1-$2 netns $1
    ip link set $2-$1 netns $2
    # Link up
    ip netns exec $2 ip link set lo up
    ip netns exec $1 ip link set lo up
    ip netns exec $2 ip link set $2-$1 up
    ip netns exec $1 ip link set $1-$2 up
    # Add ip address and gw of first node
    ip netns exec $1 ip addr add $3 dev $1-$2 
    ip netns exec $1 ip route add default via $4
    # Add gw and ip of second node
    if [ "$5" ]
    then
        ip netns exec $2 ip addr add $5 dev $2-$1 
    fi

    if [ "$6" ]
    then
        ip netns exec $2 ip route add default via $6
    fi
    return 0
}
         
add_node () {
    # add a node in its namespace
    # namespace must be unique and equal to name node
    ip netns add $1
    #ip netns exec $1 sysctl net.ipv4.ip_forward=1
    if [ "$2" ]
    then
        ip netns exec $1 /usr/share/midolman/midolman-start&
    fi
    return 0
}

add_to_root() {
    # add a node to the rootspace through a bridge (mido2nsdb)
    # bridge will be br0 and ip 10.0.0.1/8
    # Argument is the name of node (mido) and the IP address
    ip link add $1-br0 type veth peer name br0-$1
    ip link set $1-br0 netns $1
    brctl addif br0 br0-$1
    ip netns add $1
    ip link set br0-$1 up
    ip netns exec $1 ip link set $1-br0 up
    ip netns exec $1 ip link set lo up
    ip netns exec $1 ip addr add $2 dev $1-br0
    ip netns exec $1 ip route add default via 10.0.0.1
    return 0
}

# Add a common swith in root namespaces 
# so midos can connect NSDB by routing to 1.1.1.1
brctl addbr br0
ip link set br0 up
ip addr add 10.0.0.1/8 dev br0
sysctl -w net.ipv4.ip_forward=1

# Example topology
# 2 Midos and 2 host attachad to every mido
# Can't run 2 midos zookeeper detects as same host
# 2015.04.18 05:40:20.538 ERROR [main] Midolman -  main caught
#org.apache.zookeeper.KeeperException$NodeExistsException: KeeperErrorCode = NodeExists for /midonet/v1/hosts/e6c24286-befc-47e8-9cf0-e44b1a799d77/alive

# Add midos and connect to root
for i in $(seq 1 1)
do
    add_node m$i 10.0.0.$(($i+1))/8
    add_to_root m$i 10.0.0.$(($i+1))/8
done
# Add hosts and connect to midos
for i in $(seq 1 4)
do
    add_node h$i 
done
# h1 and h2 connected to mido1
# and in different subnets so we can route 
for i in $(seq 1 2)
do
    add_link h$i m1 192.168.$i.10/24 192.168.$i.1 
done
# h3 and h4 connected to mido1
# and in different subnets so we can route 
# but same subnets and h1 and h2 so we can bridge
for i in $(seq 1 2)
do
    add_link h$(($i+2)) m1 192.168.$i.11/24 192.168.$i.1 
done

# Clear all
#for i in `ip netns show`; do ip netns delete $i;done
#pkill -9 mido



