# Harmony:

	A framework for firewall aimed at at all OSI Levels

# Features

1.	An iptables wrapper to make creating rules easier

...	Supports uid/gid matching, arp tables

...	Aimed for very restrictive systems, only allows what you need

...	Easy to use config file

...	Scriptable


2.	Adshole
...	Pulls in list from various websites for dnsmasq or an OS's host file

3.	GeoIPACL
...	An Access Control List to block countries using ipset

4.	InternalAffairs
...	Parses logs to help diagnose network issues

# TODO:
	Test for non router setup
	Allow updating dns with -s/-d
	cron jobs
	add/remove rules on the fly
