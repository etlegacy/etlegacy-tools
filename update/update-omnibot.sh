#!/bin/bash

#
# ET:Legacy Omni-Bot updater - Update archives on mirror.etlegacy.com/omnibot
#

function getRevision {
    svn info $1 | sed -ne 's/^Revision: //p'
}

REPO_URL=https://subversion.assembla.com/svn/omnibot/Enemy-Territory/0.8
REVISION_REMOTE=$(getRevision ${REPO_URL})

echo "Latest Omni-bot revision is" ${REVISION_REMOTE}

if [ -d omni-bot ]; then
    REVISION_LOCAL=$(getRevision omni-bot)
    echo "Local Omni-bot revision is" ${REVISION_LOCAL} 

    if [ ${REVISION_REMOTE} -le ${REVISION_LOCAL} ]; then
	echo "Nothing to do."
	exit 
    fi
fi

svn checkout --depth empty ${REPO_URL} omni-bot
svn update --set-depth infinity omni-bot/et
svn update --set-depth infinity omni-bot/global_scripts
svn update omni-bot/omnibot_et.so
svn update omni-bot/omnibot_et.x86_64.so
svn update omni-bot/omnibot_et.dll

rm omnibot-linux-latest.tar.gz
tar --exclude '.svn/*' --exclude '.svn' -zcvf omnibot-linux-latest.tar.gz omni-bot

rm omnibot-windows-latest.zip
zip -r omnibot-windows-latest.zip omni-bot -x *.svn*

