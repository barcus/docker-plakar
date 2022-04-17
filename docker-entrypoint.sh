#!/usr/bin/env sh
#set -x

INIT=${INIT:=false}
P_PATH=${P_PATH:=~/.plakar}

if [ "${INIT}" == "true" ]; then
  echo "[!] Init plakar on ${P_PATH}"
  plakar on ${P_PATH} create -no-encryption
fi

if [ "$1" == "debug" ]; then
  echo "[!] Launch /bin/sh inside plakar container"
  exec /bin/sh
fi

echo "[!] Run plakar on ${P_PATH} $@"
exec plakar on ${P_PATH} "$@"
