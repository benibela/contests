#/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../../manageUtils.sh

githubProject contests

BASE=$HGROOT/programs/contests

case "$1" in
mirror)
  syncHg  
;;

esac

