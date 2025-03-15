Harmony
=======
A framework for a firewall aimed at at all OSI Levels

# Features

An iptables wrapper to make creating rules easier
-------------------------------------------------

Supports uid/gid matching, arp tables

Aimed for very restrictive systems, only allows what you need

Easy to use config file

Scriptable


Adshole
-------

Pulls in list from various websites for dnsmasq or an OS's host file

GeoIPACL
--------

An Access Control List to block countries using ipset

InternalAffairs
---------------

Parses logs to help diagnose network issues


install
-------
./configure --prefix=<prefix>

make install


# TODO:
	Test for non router setup
	Allow updating dns with -s/-d
	cron jobs
	add/remove rules on the fly
	write to file instead of exec'ing iptables
	add support for nftables and firewalld
	write manpanges
