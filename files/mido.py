#!/usr/bin/python

"""
The example topology creates a router and three IP subnets:
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

class Midolman( Node ):
    "A Node with Midolman enabled."

    def config( self, **params ):
        super( Midolman, self).config( **params )
        # Enable forwarding on the router
        self.cmd( 'sysctl net.ipv4.ip_forward=1' )
        self.cmd( '/usr/share/midolman/midolman-start&' )

    def terminate( self ):
        self.cmd( 'sysctl net.ipv4.ip_forward=0' )
        super( Midolman, self ).terminate()

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

    def build( self, **_opts ):

        mido1 = self.addNode( 'r0', cls=Midolman, ip='192.168.5.2/24' )
        mido2 = self.addNode( 'r1', cls=Midolman, ip='192.168.5.3/24' )
        switch = self.addSwitch( 's0', cls=LinuxBridge, ip='192.168.5.1/24')
	
	self.addLink( mido1, switch, intfName2='r0-s0')
	self.addLink( mido2, switch, intfName2='r1-s0')

        h1 = self.addHost( 'h1', ip='192.168.1.100/24',
                           defaultRoute='via 192.168.1.1' )
        h2 = self.addHost( 'h2', ip='192.168.2.100/24',
                           defaultRoute='via 192.168.2.1' )
        h3 = self.addHost( 'h3', ip='192.168.3.100/24',
                           defaultRoute='via 192.168.3.1' )

        self.addLink( h1, mido1, intfName2='r0-h1')
        self.addLink( h2, mido1, intfName2='r0-h2')
        self.addLink( h3, mido2, intfName2='r1-h3')


def run():
    "Test linux router"
    topo = NetworkTopo()
    net = Mininet( topo=topo, controller=None ) 
    # Add connectivity against host
    #os.system("ip link add veth0 type veth peer name veth1")
    #os.system("ip link set dev veth0 up")
    #os.system("ip link set dev veth1 up")
    #os.system("brctl addif s0 veth0")

    # try to get hw intf from the command line; by default, use veth1
    #intfName = sys.argv[ 1 ] if len( sys.argv ) > 1 else 'veth1'
    #_intf = Intf( intfName, node=net[ 'r0' ] )
    # Add connectivity against host
    router = net['r0']
    router.cmd('ip addr add 172.19.0.2/30 dev veth1')
    router.cmd('ip route add default via 172.19.0.1')
    net.start()
    info( '*** Routing Table on Router:\n' )
    print net[ 'r0' ].cmd( 'route' )
    print net[ 'r1' ].cmd( 'route' )
    CLI( net )
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    run()
