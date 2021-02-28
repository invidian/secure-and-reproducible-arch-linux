#!/bin/bash
set -exu

test -b "${OBV_DEVICE}"

test -n "${OBV_ID}"

# GPT partition label is limited to 36 characters, but
# ext4 labels are limited to 16 bytes.
test $(echo -n $OBV_ID | wc -c) -lt 16

# Forbid using UTF-8 characters, as /dev/mapper with 'cryptsetup open' does not handle UTF-8 characters well.
test $(echo -n $OBV_ID | wc -c) -eq ${#OBV_ID} || (echo "'$OBV_ID' may contain UTF-8 characters."; false)

parted --align=optimal $OBV_DEVICE mklabel gpt

# Parted will not execute 'mkpart' when running 'mklabel' without '--script',
# but we want to be asked for confirmation, so execute 'parted' twice.
parted --align=optimal $OBV_DEVICE mkpart $OBV_ID 0% 100% \
    print

partprobe $OBV_DEVICE
