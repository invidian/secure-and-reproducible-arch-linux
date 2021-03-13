#!/bin/bash
set -exu

IDENTIFIER=${1:-""}

test -n "${IDENTIFIER}" || (echo "Identifier given as first argument must not be empty"; false)

test -d secureboot && (echo "Secure Boot keys already generated. Run 'rm -r ./secureboot' to reset state."; exit 1)

mkdir -p secureboot && cd secureboot
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$IDENTIFIER Secure Boot Platform Key/" -keyout PK.key -out PK.crt -days 1 -nodes -sha256
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$IDENTIFIER Secure Boot Key Exchange Key/" -keyout KEK.key -out KEK.crt -days 1 -nodes -sha256
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$IDENTIFIER kernel-signing key/" -keyout db.key -out db.crt -days 1 -nodes -sha256
cert-to-efi-sig-list -g "$(uuidgen)" PK.crt PK.esl
sign-efi-sig-list -k PK.key -c PK.crt PK PK.esl PK.auth
cert-to-efi-sig-list -g "$(uuidgen)" KEK.crt KEK.esl
sign-efi-sig-list -a -k PK.key -c PK.crt KEK KEK.esl KEK.auth
cert-to-efi-sig-list -g "$(uuidgen)" db.crt db.esl
sign-efi-sig-list -a -k KEK.key -c KEK.crt db db.esl db.auth
openssl x509 -outform DER -in PK.crt -out PK.cer
openssl x509 -outform DER -in KEK.crt -out KEK.cer
openssl x509 -outform DER -in db.crt -out db.cer
cp -v KEK.esl compound_KEK.esl
cp -v db.esl compound_db.esl
sign-efi-sig-list -k PK.key -c PK.crt KEK compound_KEK.esl compound_KEK.auth
sign-efi-sig-list -k KEK.key -c KEK.crt db compound_db.esl compound_db.auth
