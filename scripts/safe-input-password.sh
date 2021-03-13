#!/bin/bash
set -eu

if [ -t 1 ]; then
  >&2 echo "Output of this command must be piped to other command!"
  exit 1
fi

>&2 echo "Type in your Master Password and press enter:"
read -s PASSWORD

>&2 echo "Confirm your password and press enter:"
read -s PASSWORD_CONFIRM

if [ ! "${PASSWORD}" == "${PASSWORD_CONFIRM}" ]; then
  >&2 echo "Passwords does not match!"
  exit 1
fi

echo $PASSWORD
