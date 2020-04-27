#!/bin/bash

#
# ET:Legacy GeoIP.dat updater - Update archives on mirror.etlegacy.com/geoip
#

curl -O https://mailfud.org/geoip-legacy/GeoIP.dat.gz
gunzip -f GeoIP.dat.gz
tar -czf GeoIP.dat.tar.gz GeoIP.dat
rm GeoIP.dat

