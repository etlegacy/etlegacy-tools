#!/bin/bash

#
# ET:Legacy WolfdAdmin updater - Update archive on mirror.etlegacy.com/wolfadmin
#
# Update WolfaAdmin from our forked version - sync the repo first with upstream!
# The legacy branch contains our Legacy integration patches
#

_SRC=`pwd`
WABRANCH="legacy"

cd ${_SRC}
if [[ ! -d "wolfadmin" ]]; then
#	git clone https://github.com/timosmit/wolfadmin.git  # upstream
	git clone https://github.com/etlegacy/wolfadmin.git  # our fork
	cd "wolfadmin"
else
	cd "wolfadmin"
	git pull -q
fi
git checkout ${WABRANCH}

cd ${_SRC}
rm -f wolfadmin.tar.gz
tar --exclude '.git/*' --exclude '.git' -zcvf wolfadmin.tar.gz wolfadmin

