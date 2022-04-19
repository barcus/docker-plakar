#!/usr/bin/env sh
#set -x

INIT=${INIT:=false}
P_PATH=${P_PATH:=~/.plakar}

if [[ "${INIT}" == "true" ]] || ! [[ -d "${P_PATH}" ]]; then
  echo "[!] Init plakar on ${P_PATH}"
  plakar on ${P_PATH} create -no-encryption
fi

if [ "$1" == "sh" ]; then
  echo "[!] Launch /bin/sh"
  exec /bin/sh
fi

echo "[!] Run plakar on ${P_PATH} $@"
exec plakar on ${P_PATH} "$@"
