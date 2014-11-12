#!/bin/bash

#
# ET:Legacy Linux assets extractor - Download and extract Wolf:ET assets
#
# - Put this script into your $HOME path or any desired folder.
# - Change permission to execute and run the script.

# TODO:
# - Add some mirrors

checksums=`mktemp`
cat >$checksums <<'EOF'
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
echo -e "       Enemy Teritorry: Legacy - ${colorG}Wolf:ET assets${reset} Linux extractor"
echo -e "${colorB}***********************************************************************${reset}"
echo

# license
note i "W:ET assets are covered by the original EULA"
note i ""
note i "See EULA_Wolfenstein_Enemy_Territory.txt at"
note i "https://github.com/etlegacy/etlegacy-tools/"
echo

if ! proceed "y" "Do you agree with the license ?"; then
    note e "Installation exited"
fi

# download
note i "Preparing extraction..."

if [ ! -f et-linux-2.60.x86.run ]; then
    note i "Fetching W:ET assets data files..."
    downloader http://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/et/linux/et-linux-2.60.x86.run
fi

# checksum
note i "Checking downloaded file..."

    sha256sum -c $checksums || note e "Integrity check failed"

# installation
note i "Extracting..."

    chmod +x et-linux-2.60.x86.run

    ./et-linux-2.60.x86.run --noexec --target WolfETassets
    rm -rf WolfETassets/{bin,Docs,README,pb,openurl.sh,CHANGES,ET.xpm,setup.{data,sh}}
    rm -rf WolfETassets/etmain/{*.cfg,*.so,*.txt,*.dat,mp_bin.pk3,video}

    cd ..

note s "Extraction successful!"

# cleaning
echo
if ! proceed "n" "Remove downloaded file archive?"; then
    rm -i et-linux-2.60.x86.run
fi

# end
echo
echo -e "${colorB}***********************************************************************${reset}"
echo -e "          You'll find the assets files in ${colorG}WolfETassets/etmain${reset}"
echo -e "${colorB}***********************************************************************${reset}"
echo -e "      Visit us on ${colorY}www.etlegacy.com${reset} and ${colorY}IRC #etlegacy@freenode.net${reset}"
echo -e "${colorB}***********************************************************************${reset}"