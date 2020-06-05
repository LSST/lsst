#!/bin/bash

set -Eeo pipefail

if [[ -n ${ANCIENT_BASH} ]]; then
  VER="bash-${ANCIENT_BASH}"
  curl -sSLO "http://ftp.gnu.org/gnu/bash/${VER}.tar.gz"
  tar -xf "${VER}.tar.gz"
  ( set -Eeo pipefail
    cd "$VER"
    yum install -y gcc make
    ./configure
    make
    yum remove -y gcc make
  )
  export PATH="${VER}:${PATH}"
  bash --version
fi

if [[ $BATCH == true ]]; then
  echo "*** testing batch mode  ***"
  bash -x ./scripts/newinstall.sh -cb
else
  echo "*** testing interactive mode***"
  echo -e "yes\\nyes" | bash -x ./scripts/newinstall.sh -c
fi

echo '*** Testing initializaion of shell environment ***'
case $MANGLER in
  tcsh)
    # csh_20110502-2ubuntu2_amd64.deb from ubuntu:trusty (travis) opens a new
    # shell interactive shell when passed--version
    tcsh --version
    cat loadLSST.csh
    # shellcheck disable=SC2016
    tcsh -ec 'source loadLSST.csh && echo "$EUPS_PKGROOT"'
    ;;
  *)
    bash --version
    cat loadLSST.bash
    bash -ec 'source loadLSST.bash && echo "$EUPS_PKGROOT"'
    ;;
esac

echo "*** Sanity checking EUPS_PKGROOT construction ***"
# shellcheck disable=SC1091
source loadLSST.bash
eups distrib install python -t v14_0_rc2

# vim: tabstop=2 shiftwidth=2 expandtab
