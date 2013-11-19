#!/bin/bash
#
# Put this script into your $HOME path or any desired folder.
# Change permission to execute and run the script.
# It'll download and install the whole ET:Legacy universe. Hf!

# Important notes:
#
# -- Don't try to overwrite previous ET: Legacy versions - it won't work!
#
# -- This is a 32 bit application - if you start ET:L and a 'file not found error'
#    is thrown ensure your system supports executing 32 bit applications

# TODO: 
# - Add some mirrors ...
# - Ask for intstall folder

{ echo "***********************************************************************"; } &&
{ echo "     ET:Legacy linux full installer script V1.03 for ET:L 2.71 RC3"; } &&
{ echo "***********************************************************************"; } &&
{ echo "ET:Legacy is published under"; } &&
{ echo "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007"; } &&
{ echo "See http://www.gnu.org/licenses/gpl-3.0"; } &&
{ echo "***********************************************************************"; } &&
{ echo "Do you accept our licence ? [y/n]"; }

read ACCEPT
if [ $ACCEPT = "y" ]
  then
  { echo "... Preparing installation ..."; }
else
  unset ACCEPT
  exit
fi
unset ACCEPT

# Fetch files
    { echo "... Fetching about 260 MB game data files - this may take a while ..."; }
    wget http://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/et/linux/et-linux-2.60.x86.run
    { echo "... Fetching  about 25 MB ET:Legacy files - it won't take long ..."; }
    wget http://mirror.etlegacy.com/etlegacy-linux-2.71rc3.zip

# Compare downloaded files against checksums
    { echo "... Checking downloaded files ..."; }
    checksums=`mktemp`
    cat >$checksums <<'EOF'
41cbbc1afb8438bc8fc74a64a171685550888856005111cbf9af5255f659ae36  et-linux-2.60.x86.run
9441e91c3c066af15527eead0aed9c65ac2022b7017977173ecb4b3f6b5f54e9  etlegacy-linux-2.71rc3.zip
EOF
    sha256sum -c $checksums || exit

    { echo "... Installing ET:Legacy ..."; }

# Permissions
    chmod +x et-linux-2.60.x86.run

# Extract
    ./et-linux-2.60.x86.run --noexec --target etlegacy
    { echo "Uncompressing ET:Legacy 2.71 RC3"; }
    unzip -q etlegacy-linux-2.71rc3.zip -d etlegacy

# Remove junk
    rm -rf etlegacy/{bin,Docs,README,pb,openurl.sh,CHANGES,ET.xpm} etlegacy/setup.{data,sh} etlegacy/etmain/*.cfg
    rm -f  etlegacy/legacy/omni-bot/omnibot_et.dll

# Do some final stuff
    chmod -f 755 etlegacy/etl
    chmod -f 755 etlegacy/etlded
    chmod -f 755 etlegacy/etlded_bot.sh
    chmod -f 755 etlegacy/etl_bot.sh
    chmod -f 664 etlegacy/legacy/omni-bot/et/user/omni-bot.cfg

# Ask for removal of .run
    { echo "Remove game data file archive? [y/n]  - You don't need that anymore"
    rm -i et-linux-2.60.x86.run; } &&

# Ask for removal of etlegacy archive
    { echo "Remove ET:Legacy archive? [y/n] - You don't need this either"
    rm -i etlegacy-linux-2.71rc3.zip; } &&

# End
{ echo "***********************************************************************"; } &&
{ echo "                 Thank you for installing ET:Legacy"; } &&
{ echo "***********************************************************************"; } &&
{ echo "      Visit us: http://www.etlegacy.com IRC #etlegacy@freenode.irc"; } &&
{ echo "***********************************************************************"; }
