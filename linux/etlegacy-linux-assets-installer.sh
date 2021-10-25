#!/bin/bash
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Authors: 2014 Remy Marquis <remy.marquis@gmail.com>
#          2021 Petr Menšík <pemensik@fedoraproject.org>

#
# ET:Legacy Linux assets extractor - Download and extract Wolf:ET assets
#
# - Put this script anywhere
# - Run it using bash or sh
# TODO:
# - Add some mirrors

checksums=`mktemp`
cat >$checksums <<'EOF'
41cbbc1afb8438bc8fc74a64a171685550888856005111cbf9af5255f659ae36  et-linux-2.60.x86.run
EOF

DIALOG=$(type -p dialog 2>/dev/null)
SUDO=$(type -p sudo 2>/dev/null)
ET_FILE=et-linux-2.60.x86.run
DSTDIR="$HOME/.etlegacy"

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

proceed_sh() {
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

proceed_dialog() {
    local DEFAULT=
    case $1 in
        y)  "$DIALOG" --yesno "$2" 0 0
            return $?;;
        n)  ! "$DIALOG" --defaultno --yesno "$2" 0 0
            return $?;;
    esac
}

proceed() {
    if [ -x "$DIALOG" ]; then
        proceed_dialog "$1" "$2"
    else
        proceed_sh "$1" "$2"
    fi
}

downloader() {
    if [ -f /usr/bin/axel  ]; then
        axel $1
    elif [ -f /usr/bin/curl  ]; then
        curl -LO $1
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

# download
note i $"Preparing extraction..."

if [ ! -f "$ET_FILE" ]; then
    if [ ! -w . ]; then
        note w $"Changing working directory to "/var/tmp"..."
        cd /var/tmp
    fi

    note i $"Fetching W:ET assets data files..."
    downloader "http://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/et/linux/$ET_FILE"
fi

# checksum
note i "Checking downloaded file..."

    sha256sum -c $checksums || note e "Integrity check failed"

# installation
note i $"Extracting license..."

    sh "$ET_FILE" --noexec --tar xf 'Docs/EULA_*.txt'
    more Docs/EULA_*.txt

if ! proceed "y" $"Do you agree with the EULA?"; then
    # User does not agree license, remove downloaded file
    rm -f "$ET_FILE"
    note e $"Installation exited"
fi

if [ -x "$SUDO" ]; then
    if proceed "n" "Install data for all users (requires sudo rights)?"; then
        RUNAS=""
    else
        RUNAS="$SUDO"
        DSTDIR="/usr/local/games/enemy-territory"
    fi
fi
note i $"Extracting assets into "$DSTDIR"..."
# RUNAS is intentionally unqoted
if $RUNAS install -d "$DSTDIR" && $RUNAS sh ./et-linux-2.60.x86.run --noexec --tar xf -C "$DSTDIR" 'etmain/pak*.pk3'
then
    note s $"Extraction successful!"
else
    note e $"Extraction failed!"
fi

# cleaning
echo
if ! proceed "n" $"Remove downloaded file archive?"; then
    rm -i "$ET_FILE"
fi

# end
echo
echo -e "${colorB}***********************************************************************${reset}"
echo -e "          You'll find the assets files in ${colorG}$DSTDIR/etmain${reset}"
echo -e "${colorB}***********************************************************************${reset}"
echo -e "      Visit us on ${colorY}www.etlegacy.com${reset} and ${colorY}IRC #etlegacy@freenode.net${reset}"
echo -e "${colorB}***********************************************************************${reset}"
