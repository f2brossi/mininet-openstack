#!/bin/sh

# Add a common swith in root namespaces
brctl addbr br0
ip link set br0 up
ip addr add 10.0.0.1/8 dev br0
# Connect mido to root namespaces so it can access the NSDB cluster
ip link add m0-eth0 type veth peer name br0-m0
ip link set m0-eth0 netns m0
brctl addif br0 br0-m0
# Prepare m0
ip netns add m0
ip link set br0-m0 up
ip netns exec m0 ip link set m0-eth0 up
ip netns exec m0 ip addr add 10.0.0.2/8 dev m0-eth0
ip netns exec m0 ip route add default via 10.0.0.1
# Run midolman
ip netns exec m0 /usr/share/midolman/midolman-start&
#ip netns exec m0 sysctl net.ipv4.ip_forward=1
# Connect one host to m0 to route with midolman
ip netns add h0
ip link add m0-h0 type veth peer name h0-m0
ip link set m0-h0 netns m0
ip netns exec m0 ip link set m0-h0 up
ip link set h0-m0 netns h0
ip netns exec h0 ip link set lo up
ip netns exec h0 ip link set h0-m0 up
ip netns exec h0 ip addr add 192.168.0.2/16 dev h0-m0
ip netns exec h0 ip route add default via 192.168.0.1
# Connect one host to m0 to route with midolman
ip netns add h1
ip link add m0-h1 type veth peer name h1-m0
ip link set m0-h1 netns m0
ip netns exec m0 ip link set m0-h1 up
ip link set h1-m0 netns h1
ip netns exec h1 ip link set lo up
ip netns exec h1 ip link set h1-m0 up
ip netns exec h1 ip addr add 192.168.0.3/16 dev h1-m0
ip netns exec h1 ip route add default via 192.168.0.1
# MIDONET-CLI
midonet> list host
host host0 name vagrant-ubuntu-trusty-64 alive true
midonet> list host host0 interface 
iface m0-eth0 host_id host0 status 3 addresses [u'10.0.0.2', u'fe80:0:0:0:b854:77ff:fe44:e08b'] mac ba:54:77:44:e0:8b mtu 1500 type Virtual endpoint UNKNOWN
iface lo host_id host0 status 0 addresses [] mac 00:00:00:00:00:00 mtu 65536 type Virtual endpoint LOCALHOST
iface midonet host_id host0 status 0 addresses [] mac 5a:76:3c:7c:a6:97 mtu 1500 type Virtual endpoint DATAPATH
iface m0-h0 host_id host0 status 3 addresses [u'fe80:0:0:0:d471:f4ff:fe12:1b6e'] mac d6:71:f4:12:1b:6e mtu 1500 type Virtual endpoint UNKNOWN
iface m0-h1 host_id host0 status 3 addresses [u'fe80:0:0:0:84bf:f4ff:fe23:dcec'] mac 86:bf:f4:23:dc:ec mtu 1500 type Virtual endpoint UNKNOWN
midonet> create tunnel-zone name new-tz type gre
tzone0
midonet> router create name test-router
router0
midonet> tunnel-zone tzone0 add member host host0 address 10.0.0.2
zone tzone0 host host0 address 10.0.0.2
midonet> router router0 add port address 192.168.0.1 net 192.168.0.1/16
router0:port0
midonet> bridge create name test-bridge
bridge0
midonet> bridge bridge0 add port
bridge0:port0
midonet> host host0 add binding port bridge0:port0 interface m0-h0
host host0 interface m0-h0 port bridge0:port0
midonet> bridge bridge0 add port
bridge0:port1
midonet> host host0 add binding port bridge0:port1 interface m0-h1
host host0 interface m0-h1 port bridge0:port1
# Test virtual switch
ip netns exec h1 ping 192.168.0.2
PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
64 bytes from 192.168.0.2: icmp_seq=1 ttl=64 time=315 ms
# Let's route
midonet> bridge bridge0 add port
bridge0:port2
midonet> router router0 port port0 set peer bridge0:port2
# Test it
root@vagrant-ubuntu-trusty-64:~# ip netns exec h1 ping 192.168.0.1
PING 192.168.0.1 (192.168.0.1) 56(84) bytes of data.
^C
--- 192.168.0.1 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2001ms

root@vagrant-ubuntu-trusty-64:~# ip netns exec h1 arp -a
? (192.168.0.2) at 3a:f4:25:96:45:b3 [ether] on h1-m0
? (192.168.0.1) at ac:ca:ba:64:a2:a2 [ether] on h1-m0
? (192.168.0.1) at ac:ca:ba:64:a2:a2 [ether] on h1-m0



