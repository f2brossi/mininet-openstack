#!/usr/bin/python

"""
linuxrouter.py: Example network with Linux IP router

This example converts a Node into a router using IP forwarding
already built into Linux.

The example topology creates a router and three IP subnets:

    - 192.168.1.0/24 (r0-eth1, IP: 192.168.1.1)
    - 172.16.0.0/12 (r0-eth2, IP: 172.16.0.1)
    - 10.0.0.0/8 (r0-eth3, IP: 10.0.0.1)

Each subnet consists of a single host connected to
a single switch:

    r0-eth1 - s1-eth1 - h1-eth0 (IP: 192.168.1.100)
    r0-eth2 - s2-eth1 - h2-eth0 (IP: 172.16.0.100)
    r0-eth3 - s3-eth1 - h3-eth0 (IP: 10.0.0.100)

The example relies on default routing entries that are
automatically created for each router interface, as well
as 'defaultRoute' parameters for the host interfaces.

Additional routes may be added to the router or hosts by
executing 'ip route' or 'route' commands on the router or hosts.
"""
import sys
import os

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import Node
from mininet.log import setLogLevel, info
from mininet.cli import CLI
from mininet.link import Intf
from mininet.nodelib import LinuxBridge

class LinuxRouter( Node ):
    "A Node with IP forwarding enabled."

    def config( self, **params ):
        super( LinuxRouter, self).config( **params )
        # Enable forwarding on the router
        self.cmd( 'sysctl net.ipv4.ip_forward=1' )

    def terminate( self ):
        self.cmd( 'sysctl net.ipv4.ip_forward=0' )
        super( LinuxRouter, self ).terminate()


class NetworkTopo( Topo ):
    "A LinuxRouter connecting three IP subnets"

    def build( self, **_opts ):

        defaultIP = '192.168.1.1/24'  # IP address for r0-eth1
        router = self.addNode( 'r0', cls=LinuxRouter, ip=defaultIP )

        h1 = self.addHost( 'h1', ip='192.168.1.100/24',
                           defaultRoute='via 192.168.1.1' )
        h2 = self.addHost( 'h2', ip='172.16.0.100/12',
                           defaultRoute='via 172.16.0.1' )
        h3 = self.addHost( 'h3', ip='10.0.0.100/8',
                           defaultRoute='via 10.0.0.1' )

        self.addLink( h1, router, intfName2='r0-h1',
                      params2={ 'ip' : defaultIP } )  # for clarity
        self.addLink( h2, router, intfName2='r0-h2',
                      params2={ 'ip' : '172.16.0.1/12' } )
        self.addLink( h3, router, intfName2='r0-h3',
                      params2={ 'ip' : '10.0.0.1/8' } )


        switch = self.addSwitch( 's0', cls=LinuxBridge, ip='172.19.0.1/30')



def run():
    "Test linux router"
    topo = NetworkTopo()
    net = Mininet( topo=topo, controller=None ) 
    # Add connectivity against host
    os.system("ip link add veth0 type veth peer name veth1")
    os.system("ip link set dev veth0 up")
    os.system("ip link set dev veth1 up")

    # try to get hw intf from the command line; by default, use veth1
    intfName = sys.argv[ 1 ] if len( sys.argv ) > 1 else 'veth1'
    _intf = Intf( intfName, node=net[ 'r0' ] )
    # Add connectivity against host
    router = net['r0']
    router.cmd('ip addr add 172.19.0.2/30 dev veth1')
    router.cmd('ip route add default via 172.19.0.1')
    net.start()
    info( '*** Routing Table on Router:\n' )
    print net[ 'r0' ].cmd( 'route' )
    CLI( net )
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    run()
