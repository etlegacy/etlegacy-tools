#!/bin/bash

#
# ET: Legacy Linux full installer - Download and install the whole ET: Legacy universe. Hf!
#
# - Put this script into your $HOME path or any desired folder.
# - Change permission to execute and run the script.
#
# Important notes:
# - Don't try to overwrite previous ET: Legacy versions - it won't work!
# - This is a 32 bit application - if you start ET:L and a 'file not found error'
#   is thrown ensure your system supports executing 32 bit applications

# TODO:
# - Add some mirrors
# - Add option for the 64 bit version

version="2.71a"

checksums=`mktemp`
cat >$checksums <<'EOF'
4a594f7246f762ffedfba845fbc32d9fd07487dfa0914ab5f4eff1e97c02a57c  etlegacy-2.71a-linux-i686.tar.gz
41cbbc1afb8438bc8fc74a64a171685550888856005111cbf9af5255f659ae36  et-linux-2.60.x86.run
EOF

#
# Tools
#

reset="\e[0m"
colorR="\e[1;31m"
colorG="\e[1;32m"
colorY="\e[1;33m"
colorB="\e[1;34m"

note() {
    case "$1" in
        i) echo -e "${colorB}::${reset} $2";;   # info
        s) echo -e "${colorG}::${reset} $2";;   # success
        w) echo -e "${colorY}::${reset} $2";;   # question
        e) echo -e "${colorR}::${reset} $2";    # error
            exit 1;;
    esac
}

proceed() {
    case $1 in
        y)  printf "${colorY}%s${reset} ${colorW}%s${reset}" "::" $"$2 [Y/n] "
            read -n 1 answer
            echo
            case $answer in
                Y|y|'') return 0;;
                *) return 1;;
            esac;;
        n)  printf "${colorY}%s${reset} ${colorW}%s${reset}" "::" $"$2 [y/N] "
            read -n 1 answer
            echo
            case $answer in
                N|n|'') return 0;;
                *) return 1;;
            esac;;
    esac
}

downloader() {
    if [ -f /usr/bin/axel  ]; then
        axel $1
    elif [ -f /usr/bin/curl  ]; then
        curl -O $1
    else
        wget $1
    fi
}

#
# Main
#

echo -e "${colorB}***********************************************************************${reset}"
echo -e "           Enemy Teritorry: Legacy ${colorG}$version${reset} Linux full installer"
echo -e "${colorB}***********************************************************************${reset}"
echo

# license
note i "ET: Legacy is published under the GNU GPLv3 license"
note i "See http://www.gnu.org/licenses/gpl-3.0"
note i ""
note i "W:ET assets are still covered by the original EULA"
note i "See EULA_Wolfenstein_Enemy_Territory.txt at"
note i "https://github.com/etlegacy/etlegacy-tools/"
echo

if ! proceed "y" "Do you agree with the licenses ?"; then
    note e "Installation exited"
fi

# download
note i "Preparing installation..."

if [ ! -f et-linux-2.60.x86.run ]; then
    note i "Fetching W:ET assets data files..."
    downloader http://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/et/linux/et-linux-2.60.x86.run
fi
if [ ! -f etlegacy-${version}-linux-i686.tar.gz ]; then
    note i "Fetching ET: Legacy files..."
    downloader http://mirror.etlegacy.com/release/etlegacy-${version}-linux-i686.tar.gz
fi
#if [ ! -f omnibot-linux-latest.tar.gz ]; then
#    note i "Fetching Omni-bot files..."
#    downloader http://mirror.etlegacy.com/omnibot/omnibot-linux-latest.tar.gz
#fi

# checksum
note i "Checking downloaded files..."

    sha256sum -c $checksums || note e "Integrity check failed"

# installation
note i "Installing..."

    chmod +x et-linux-2.60.x86.run

    ./et-linux-2.60.x86.run --noexec --target etlegacy
    rm -rf etlegacy/{bin,Docs,README,pb,openurl.sh,CHANGES,ET.xpm} etlegacy/setup.{data,sh} etlegacy/etmain/{*.cfg,*.so,*.txt,*.dat,mp_bin.pk3}

    tar -zxvf etlegacy-${version}-linux-i686.tar.gz

    cd etlegacy

    chmod -f 755 etl
    chmod -f 755 etlded
    chmod -f 755 etlded_bot.sh
    chmod -f 755 etl_bot.sh

    #tar -zxvf ../omnibot-linux-latest.tar.gz
    #chmod -f 664 omni-bot/et/user/omni-bot.cfg

    cd ..

note s "Installation successful!"

# cleaning
echo
if ! proceed "n" "Remove downloaded files archive?"; then
    rm -i et-linux-2.60.x86.run
    rm -i etlegacy-${version}-linux-i686.tar.gz
    #rm -i omnibot-linux-latest.tar.gz
fi

# end
echo
echo -e "${colorB}***********************************************************************${reset}"
echo -e "                 ${colorR}Thank you for installing ET: Legacy${reset}"
echo -e "${colorB}***********************************************************************${reset}"
echo -e "      Visit us on ${colorY}www.etlegacy.com${reset} and ${colorY}IRC #etlegacy@freenode.net${reset}"
echo -e "${colorB}***********************************************************************${reset}"
