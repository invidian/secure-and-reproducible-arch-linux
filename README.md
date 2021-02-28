# Secure and reproducible Arch Linux

This guide has the following goals:
- Automate secure installation of Arch Linux.
- Document security best practices and processes around performing backups, using YubiKeys, operating Secure Boot etc. in a single place.
- Provide optimal security against unauthorized access to online services you use.
- Provide optimal security against unauthorized access to data on your devices.

This guide is mainly targets developers and system administrators using Linux as daily operating system on their workstations, which either use or would like to use Arch Linux.

## Table of Contents
- [Secure and reproducible Arch Linux](#secure-and-reproducible-arch-linux)
  * [Table of Contents](#table-of-contents)
  * [Assumptions](#assumptions)
    + [Security of your Daily Password Manager](#security-of-your-daily-password-manager)
      - [Regular authentication methods for Daily Password Manager](#regular-authentication-methods-for-daily-password-manager)
        * [Copy of your Daily Password Manager database file](#copy-of-your-daily-password-manager-database-file)
        * [Your Master Password](#your-master-password)
        * [Challenge Secret from your Hardware Security Module](#challenge-secret-from-your-hardware-security-module)
      - [Attack vectors for Daily Password Manager](#attack-vectors-for-daily-password-manager)
        * [Compromising your machine on software level](#compromising-your-machine-on-software-level)
        * [Getting physical access to your unlocked machine with unlocked password manager](#getting-physical-access-to-your-unlocked-machine-with-unlocked-password-manager)
    + [Security of your online services](#security-of-your-online-services)
      - [Regular authentication methods for online services](#regular-authentication-methods-for-online-services)
        * [High-entropy unique password](#high-entropy-unique-password)
        * [OATH TOTP (Time-based One-Time Password)](#oath-totp-time-based-one-time-password)
        * [Physical possession and presence of Hardware Security Module](#physical-possession-and-presence-of-hardware-security-module)
        * [FIDO2 PIN (usually Master PIN)](#fido2-pin-usually-master-pin)
      - [Special authentication methods for online services](#special-authentication-methods-for-online-services)
        * [MFA Recovery codes](#mfa-recovery-codes)
      - [Attack vectors for online services](#attack-vectors-for-online-services)
        * [Compromising your Daily Password Manager via software](#compromising-your-daily-password-manager-via-software)
        * [Getting physical access to your unlocked machine with unlocked password manager](#getting-physical-access-to-your-unlocked-machine-with-unlocked-password-manager-1)
        * [Compromising online service itself](#compromising-online-service-itself)
        * [Man-in-the-middle (MITM)](#man-in-the-middle-mitm)
        * [Phishing](#phishing)
        * [Session hijacking](#session-hijacking)
    + [Security of your data](#security-of-your-data)
      - [PC disk](#pc-disk)
        * [Regular authentication methods for PC disks](#regular-authentication-methods-for-pc-disks)
          + [Access to your disk](#access-to-your-disk)
          + [Encryption key](#encryption-key)
          + [Master PIN](#master-pin)
          + [Hardware Security Module](#hardware-security-module)
          + [TPM secret](#tpm-secret)
        * [Special authentication methods for PC disks](#special-authentication-methods-for-pc-disks)
          + [Recovery key](#recovery-key)
        * [Attack vectors for PC disks](#attack-vectors-for-pc-disks)
          + [Software attack](#software-attack)
          + [Physical access to your unlocked machine](#physical-access-to-your-unlocked-machine)
      - [Mobile phone built-in storage](#mobile-phone-built-in-storage)
        * [Regular authentication methods for mobile built-in storage](#regular-authentication-methods-for-mobile-built-in-storage)
          + [Physical access](#physical-access)
          + [Encryption password](#encryption-password)
        * [Attack vectors for mobile built-in storage](#attack-vectors-for-mobile-built-in-storage)
          + [Software remote attack](#software-remote-attack)
          + [Extraction of encryption keys from memory](#extraction-of-encryption-keys-from-memory)
          + [Physical access with fingerprint scan to your turned on and locked device](#physical-access-with-fingerprint-scan-to-your-turned-on-and-locked-device)
          + [Physical access to your unlocked device](#physical-access-to-your-unlocked-device)
      - [Local backup storage](#local-backup-storage)
        * [Regular authentication methods for local backup storage](#regular-authentication-methods-for-local-backup-storage)
          + [Encryption key](#encryption-key-1)
          + [Hardware Security Module](#hardware-security-module-1)
          + [Master PIN](#master-pin-1)
        * [Special authentication methods for local backup storage](#special-authentication-methods-for-local-backup-storage)
          + [Recovery key](#recovery-key-1)
        * [Attack vectors for local backup storage](#attack-vectors-for-local-backup-storage)
          + [Compromising remote system acting as local backup storage](#compromising-remote-system-acting-as-local-backup-storage)
          + [Compromising your machine which has access to your local backup storage](#compromising-your-machine-which-has-access-to-your-local-backup-storage)
      - [Remote backup storage](#remote-backup-storage)
        * [Regular authentication methods for Borg](#regular-authentication-methods-for-borg)
          + [Hardware Security Module](#hardware-security-module-2)
          + [Master PIN](#master-pin-2)
          + [Backup password](#backup-password)
        * [Special authentication methods for Borg](#special-authentication-methods-for-borg)
          + [Master GPG Key](#master-gpg-key)
          + [Deployment SSH Keys](#deployment-ssh-keys)
        * [Attack vectors for remote backup storage with Borg](#attack-vectors-for-remote-backup-storage-with-borg)
    + [Summary](#summary)
  * [Requirements](#requirements)
    + [Detailed list](#detailed-list)
      - [1 x (or more) x86 Computer with UEFI support (and recommended Secure Boot and TPM support)](#1-x-or-more-x86-computer-with-uefi-support-and-recommended-secure-boot-and-tpm-support)
      - [1 x Temporary Computer running Linux, Windows or macOS](#1-x-temporary-computer-running-linux-windows-or-macos)
      - [2 x Hardware security device with PIV, OpenPGP and OATH - HOTP support like](#2-x-hardware-security-device-with-piv-openpgp-and-oath---hotp-support-like-)
      - [2 x Dedicated removable storage device (e.g. pendrive) for offline backup of master keys and passwords](#2-x-dedicated-removable-storage-device-eg-pendrive-for-offline-backup-of-master-keys-and-passwords)
      - [2 x Dedicated removable storage device (e.g. pendrive) for a OS recovery volume](#2-x-dedicated-removable-storage-device-eg-pendrive-for-a-os-recovery-volume)
      - [1 x Temporary removable storage device (e.g. pendrive) for temporary storage](#1-x-temporary-removable-storage-device-eg-pendrive-for-temporary-storage)
      - [1 x Dedicated removable storage device (e.g. USB HDD, network disk) for local backups](#1-x-dedicated-removable-storage-device-eg-usb-hdd-network-disk-for-local-backups)
      - [1 x Dedicated remote storage server for remote backups (with SSH support for Borg or S3-like support for restic)](#1-x-dedicated-remote-storage-server-for-remote-backups-with-ssh-support-for-borg-or-s3-like-support-for-restic)
    + [Summary](#summary-1)
  * [Bootstrapping](#bootstrapping)
    + [Preparation](#preparation)
      - [Getting Arch Linux installation medium](#getting-arch-linux-installation-medium)
        * [Configuring Arch Linux ISO](#configuring-arch-linux-iso)
          + [Connecting to the Wi-Fi](#connecting-to-the-wi-fi)
          + [Expanding available disk space](#expanding-available-disk-space)
          + [Installing and running graphical interface](#installing-and-running-graphical-interface)
      - [Fetching required resources into temporary volume](#fetching-required-resources-into-temporary-volume)
        * [Format and mount temporary volume](#format-and-mount-temporary-volume)
        * [Fetching repository](#fetching-repository)
        * [Fetching dependencies](#fetching-dependencies)
      - [Rebooting into offline mode](#rebooting-into-offline-mode)
        * [Ensure you will be offline](#ensure-you-will-be-offline)
        * [Mounting temporary volume](#mounting-temporary-volume)
        * [Installing dependencies offline](#installing-dependencies-offline)
    + [Creating secrets](#creating-secrets)
      - [Master Password](#master-password)
        * [Recovery](#recovery)
          + [Sharding](#sharding)
          + [Distribution](#distribution)
          + [Periodic verification](#periodic-verification)
          + [Rotating Master Password](#rotating-master-password)
          + [Combining shards](#combining-shards)
      - [Backup volumes](#backup-volumes)
        * [Identifying plugged devices](#identifying-plugged-devices)
        * [Formatting](#formatting)
        * [Safe removal](#safe-removal)
        * [Mounting secure volume again](#mounting-secure-volume-again)
        * [Initializing](#initializing)
        * [Summary](#summary-2)
      - [Master PIN](#master-pin-3)
      - [Configuring YubiKeys](#configuring-yubikeys)
        * [Setting up HMAC-SHA1 Challenge-Response](#setting-up-hmac-sha1-challenge-response)
          + [Generating access code](#generating-access-code)
          + [Generating configuration](#generating-configuration)
          + [Writing configuration to devices](#writing-configuration-to-devices)
        * [Setting up PIV applet](#setting-up-piv-applet)
          + [Generating management key](#generating-management-key)
          + [Generating PUK](#generating-puk)
          + [Setting PIN](#setting-pin)
        * [Setting up GPG smartcard](#setting-up-gpg-smartcard)
          + [Setting Admin PIN](#setting-admin-pin)
      - [Generating GPG keys](#generating-gpg-keys)
        * [Prepare GPG configuration](#prepare-gpg-configuration)
        * [Generate keys](#generate-keys)
        * [Transfering keys into YubiKeys](#transfering-keys-into-yubikeys)
      - [Generating Secure Boot keys](#generating-secure-boot-keys)
        * [Transferring Database Key into YubiKeys](#transferring-database-key-into-yubikeys)
      - [Creating Arch Linux bootable USB device](#creating-arch-linux-bootable-usb-device)
      - [Q&A List](#qa-list)
  * [Day-2 Operations](#day-2-operations)
    + [Machine Maintenance](#machine-maintenance)
      - [Booting up](#booting-up)
      - [OS Installation](#os-installation)
      - [Updating system configuration and rebuilding Recovery ISO image](#updating-system-configuration-and-rebuilding-recovery-iso-image)
      - [Updating Kernel](#updating-kernel)
      - [Updating BIOS](#updating-bios)
      - [Bootstrapping new hardware](#bootstrapping-new-hardware)
    + [YubiKey Maintenance](#yubikey-maintenance)
      - [Adding new OATH-TOTP secret](#adding-new-oath-totp-secret)
      - [Provisioning new YubiKey](#provisioning-new-yubikey)
      - [Unlocking locked Master PIN](#unlocking-locked-master-pin)
    + [Using Offline Backup Volume](#using-offline-backup-volume)
      - [Accessing](#accessing)
      - [Signing someone else's GPG key](#signing-someone-elses-gpg-key)
      - [Storing MFA recovery tokens](#storing-mfa-recovery-tokens)
      - [Extending expiry time of your GPG keys](#extending-expiry-time-of-your-gpg-keys)
      - [Rotating Master Password](#rotating-master-password-1)
    + [Incident responses](#incident-responses)
      - [Compromised Daily Password Manager copy](#compromised-daily-password-manager-copy)
      - [Compromised Daily Password Manager content](#compromised-daily-password-manager-content)
      - [Compromised Offline Backup Volume](#compromised-offline-backup-volume)
      - [Compromised machine running unauthorized code](#compromised-machine-running-unauthorized-code)
      - [Compromised Master Password](#compromised-master-password)
      - [Compromised Master PIN](#compromised-master-pin)
      - [Destroyed single Offline Backup Volume](#destroyed-single-offline-backup-volume)
      - [Destroyed both Offline Backup Volumes](#destroyed-both-offline-backup-volumes)
      - [Destroyed single YubiKey](#destroyed-single-yubikey)
      - [Destroyed all YubiKeys](#destroyed-all-yubikeys)
      - [Destroyed Disk encryption header](#destroyed-disk-encryption-header)
      - [Destroyed Disk encryption key](#destroyed-disk-encryption-key)
      - [Destroyed TPM Secret](#destroyed-tpm-secret)
      - [Revoking your GPG sub-keys](#revoking-your-gpg-sub-keys)
      - [Restoring your Master Password from shards](#restoring-your-master-password-from-shards)
      - [A password gets compromised](#a-password-gets-compromised)
  * [Miscellaneous](#miscellaneous)
    + [Trying out this guide in virtualized environment](#trying-out-this-guide-in-virtualized-environment)
    + [Block-based backups vs File-based backups](#block-based-backups-vs-file-based-backups)
    + [Credentials which shouldn't be stored in [Daily Password Manager](#daily-password-manager)](#credentials-which-shouldnt-be-stored-in-daily-password-manager%23daily-password-manager)
      - [MFA Recovery Codes/Tokens](#mfa-recovery-codestokens)
      - [Password Salt](#password-salt)
      - [API Keys for services with MFA enabled](#api-keys-for-services-with-mfa-enabled)
      - [Private keys](#private-keys)
      - [Master Password and Master PIN](#master-password-and-master-pin)
      - [GPG AdminPIN and PIV PUK](#gpg-adminpin-and-piv-puk)
      - [Disk encryption recovery keys](#disk-encryption-recovery-keys)
      - [TPM Passwords](#tpm-passwords)
    + [Credentials which can be stored in [Daily Password Manager](#daily-password-manager)](#credentials-which-can-be-stored-in-daily-password-manager%23daily-password-manager)
      - [BIOS Password](#bios-password)
    + [Why Secure Boot keys do not require periodic rotation](#why-secure-boot-keys-do-not-require-periodic-rotation)
    + [Why does Secure Boot keys do not require respecting expiry time](#why-does-secure-boot-keys-do-not-require-respecting-expiry-time)
    + [Technology used by this guide](#technology-used-by-this-guide)
    + [What this guide does not protect from](#what-this-guide-does-not-protect-from)
      - [Operating on compromised machine](#operating-on-compromised-machine)
      - [Apartment theft](#apartment-theft)
    + [AES-256 security](#aes-256-security)
    + [Old Android phone as Offline Password Manager](#old-android-phone-as-offline-password-manager)
  * [Glossary](#glossary)
    + [Daily Password Manager](#daily-password-manager)
    + [Offline Password Manager](#offline-password-manager)
    + [3-2-1 Backup Rule](#3-2-1-backup-rule)
    + [Snowflake](#snowflake)
    + [Offline Recovery Volume](#offline-recovery-volume)
    + [GPG Master Key](#gpg-master-key)
    + [GPG Sub-keys](#gpg-sub-keys)
    + [Master Password](#master-password-1)
    + [Offline Backup Volume](#offline-backup-volume)
    + [Secure Boot Platform Key (PK)](#secure-boot-platform-key-pk)
    + [OS Recovery Volume](#os-recovery-volume)
    + [MFA/2FA - Multi/Two Factor Authentication](#mfa2fa---multitwo-factor-authentication)
    + [MFA Recovery Token](#mfa-recovery-token)

## Assumptions

This section describes used security measures in designed setup and possible attack scenarios against the data which this guide tries to protect.

Each of the protected resource is broken down into "regular" authentication method, special authentication method (if applicable) and possible attack vectors.

### Security of your Daily Password Manager

#### Regular authentication methods for Daily Password Manager

In the regular circumstances, your Daily Password Manager will be protected by the following factors:

##### [Copy of your Daily Password Manager database file](#copy-of-your-daily-password-manager-database-file)

This data will be stored on the following devices:

- Any of your daily devices like laptop or mobile phone.
- Your local backup device.
- Your remote backup storage.

#

##### [Your Master Password](#your-master-password)

This password should never be written down or stored directly to make it harder to leak. Harder does not mean impossible, as for example, if you type your password on a compromised device (e.g. with software keylogger) or via hardware keylogger, your password will effectively be compromised. This is why it is important to only type your Master Password on trusted devices.

#

##### [Challenge Secret from your Hardware Security Module](#challenge-secret-from-your-hardware-security-module)

Last factor required to get access to your password manager is a physical possession and physical presence of your Hardware Security Device, in this case YubiKey.

E.g. if someone takes over your machine using remote control software, they won't be able to open your locked password manager.

```diff
+ During regular operation, only possession of your YubiKey make it possible to unlock the password database.
+ Alternatively, one must additionally posses the secret used to configure the YubiKey.
+ In case of brute-force attack, using HSM increases the entropy of the encryption key for the database.
```

#

#### Attack vectors for Daily Password Manager

An attacker may have additional ways of getting information from your password manager. This includes scenarios like:

##### [Compromising your machine on software level](#compromising-your-machine-on-software-level)

If an attacker manages to trick you into pulling rogue software update or running some rogue software on your machine, so they can take it over, they may then remotely access data in your password manager.

#

##### [Getting physical access to your unlocked machine with unlocked password manager](#getting-physical-access-to-your-unlocked-machine-with-unlocked-password-manager)

If you leave your machine unattended and unlocked, your password manager can be easily compromised.

#

### Security of your online services

#### Regular authentication methods for online services

The security of online services you use will differ from service to service. All services are usually protected with the following measures:

##### [High-entropy unique password](#high-entropy-unique-password)

Using password manager allows you to use unique password for every service, with optimal level of entropy to make used password impossible to brute-force.

```diff
+ Using unique password for each service ensures, that even if one password leaks in any way, only single service is affected by this. It prevents attacker from gaining access to your other accounts using the same password.
+ Using high-entropy passwords makes it almost impossible to brute-force. If attacker gets access to hashed version of your password, they won't be able to make use of it anyway.
```



#

Some services over MFA authentication using the following mechanism:

##### [OATH TOTP (Time-based One-Time Password)](#oath-totp-time-based-one-time-password)

Most popular 2nd authentication factor (2FA). In this guide, TOTP secrets are stored on YubiKey and obtaining them requires physical touch of the device. This means if someone compromises your machine remotely, they won't be able to obtain codes required for logging in into the services.

```diff
+ Using TOTP baked by hardware key protects your accounts if your machine gets compromised via software.
```



#

Some services may also offer FIDO2 authentication. In such case, the protection is based on 2 factors:

##### [Physical possession and presence of Hardware Security Module](#physical-possession-and-presence-of-hardware-security-module)

YubiKey offers FIDO2 authentication, where secret key is stored on your YubiKey and touch is required to confirm physical presence.

#

##### [FIDO2 PIN (usually Master PIN)](#fido2-pin-usually-master-pin)

As a second factor, PIN is used so even if someone steals your security key, they won't be able to use it to impersonate you.

#

#### Special authentication methods for online services

##### [MFA Recovery codes](#mfa-recovery-codes)

In case you lose access to both of your YubiKeys, you should have special MFA recovery codes backed up on [Offline Backup Volume](#offlline-backup-volume), which should allow you to re-gain access to your account.

#### Attack vectors for online services

When attacker wants to take over your online account, they have the following attack vectors:

##### [Compromising your Daily Password Manager via software](#compromising-your-daily-password-manager-via-software)

If an attacker gets remote access to your Daily Password Manager, they can then access all the services, which are not protected by MFA. Services protected with OATH-TOTP or FIDO2 should remain safe.

#

##### [Getting physical access to your unlocked machine with unlocked password manager](#getting-physical-access-to-your-unlocked-machine-with-unlocked-password-manager-1)

If you leave your machine unattended, including security key plugged in, an attacker with physical access may access all your accounts, **including ones protected with OATH-TOTP**. Only accounts protected using FIDO2 should remain safe, as they require Master PIN every time you authenticate.

Do note, that an attacker with physical access may install a keylogger on your machine and trick you to provide your Master PIN, then again access your machine unattended and compromise all your accounts.

#

##### [Compromising online service itself](#compromising-online-service-itself)

If targeted online service itself is vulnerable to some attacks, exploiting such vulnerability may allow an attacker to take over your account in there.

#

##### [Man-in-the-middle (MITM)](#man-in-the-middle-mitm)

If network environment you work in is controlled by attacker, they may trick you into visiting their own version of service to trick you to send them your password. In such scenario, again, accounts using MFA should remain secure.

In case of MITM attacks, an attacker may also try to steal your browser cookies, which will allow to access your account, bypassing authentication requirement.

Using VPN provides good protection against MITM attacks.

#

##### [Phishing](#phishing)

An attacker may try to trick you into telling them you own password. This scenario is also safe for accounts using MFA.

#

##### [Session hijacking](#session-hijacking)

If online service is vulnerable to [XSS](https://en.wikipedia.org/wiki/Cross-site_scripting) vulnerability, they may try to trick you into clicking a link which opening will result in sending your session cookies to the attacker, so they can impersonate you bypassing the authentication.

One can try to protect themselves against such attacks by disabling or conditionally enabling JavaScript on the websites you visit.

#

### Security of your data

Security of your data will depend on where the data is stored. For each data storage, we will again identify protection measures and attack vectors.

With this guide we identify the following storages for your data:

- PC disk
- Mobile phone built-in storage
- Local backup storage
- Remote backup storage
- Offline Backup Volume

#### PC disk

With this guide all your disks are protected using Full Disk Encryption done with LUKS.

##### Regular authentication methods for PC disks

###### [Access to your disk](#access-to-your-disk)

This may sound obvious, but for accessing your encrypted data, either physical presence or authenticated network access must be satisfied to get access to your data.

#

###### [Encryption key](#encryption-key)

For each of your disk there will be unique encryption key generated with entropy level, which makes brute-forcing such key infeasible. In regular use, this key will be additionally protected with GPG encryption.

#

###### [Master PIN](#master-pin)

As your disk encryption key is encrypted, your GPG encryption key stored on YubiKey will be needed every time you need to decrypt your PC disk and in order to use your GPG encryption key, you must provide your Master PIN, which should only be stored in your memory.

#

###### [Hardware Security Module](#hardware-security-module)

As your disk encryption key is encrypted, your GPG encryption key stored on YubiKey will be needed every time you need to decrypt your PC disk.

#

###### [TPM secret](#tpm-secret)

In addition to the encryption key, there will be a secret generated, which will be stored in TPM of your device. This ensures, that your data can only be accessed on your machine running your, trusted software.

#

##### Special authentication methods for PC disks

###### [Recovery key](#recovery-key)

In addition to the authentication methods above, there will be secondary encryption key generated, which will be stored in [Offline Backup Volume](#offline-backup-volume). It can be used in the following situations:

- Your machine BIOS gets updated.
- You lose your encryption key.
- Your TPM gets wiped.
- Your machine gets damaged (e.g. access to TPM, but not HDD).

In order to access the Recovery Key, you must first have access to Offline Backup Volume described below.

#

##### Attack vectors for PC disks

###### [Software attack](#software-attack)

If your machine gets compromised via software, an attacker will effectively bypass the authentication and gets access to all your data.

#

###### [Physical access to your unlocked machine](#physical-access-to-your-unlocked-machine)

If you leave your machine unlocked, an attacker with physical access to it may access and dump all the data stored on it.

#

#### Mobile phone built-in storage

With mobile devices, we cannot have as sophisticated security settings as with PC disks, so this section describes what is used for mobile devices.

##### Regular authentication methods for mobile built-in storage

###### [Physical access](#physical-access)

Mobile devices cannot be decrypted remotely, so physical access to the device is required to get access to data stored on it.

#

###### [Encryption password](#encryption-password)

Mobile device will have encryption password set, which is stored in the security module on device itself, which should protect it against brute-force attacks.

#

##### Attack vectors for mobile built-in storage

###### [Software remote attack](#software-remote-attack)

If your device is running vulnerable software and it's turned on, it might get exploited which will give an attacker remote access to your data.

#

###### [Extraction of encryption keys from memory](#extraction-of-encryption-keys-from-memory)

Qualified attacker may also extract encryption keys from your device RAM, assuming it has physical access to your device, then use this encryption key to get access to your data.

#

###### [Physical access with fingerprint scan to your turned on and locked device](#physical-access-with-fingerprint-scan-to-your-turned-on-and-locked-device)

If your device gets stolen locked and attacker will posses your fingerprint, they may get access to data stored on your device.

```diff
- The fingerprint can be taken from the device itself, making this attack relatively easy.
```

#

###### [Physical access to your unlocked device](#physical-access-to-your-unlocked-device)

If an attacker manages to posses your mobile device unlocked (e.g. stealing it), they immediately get access to all your data **and all online services you are logged into.** 

#

#### Local backup storage

Your local backup storage might be less secure than your PC disk, due to the fact that it might be accessed from multiple devices. Depending on architecture of your local storage, you will use different authentication methods.

##### Regular authentication methods for local backup storage

###### [Encryption key](#encryption-key)

If your local backup storage is a portable disk, similar to PC disk protection, it will be protected using encrypted encryption key, which should be stored on all devices accessing your disk.

#

###### [Hardware Security Module](#hardware-security-module)

If your local backup storage is a portable disk, similar to PC disk protection, to decrypt encryption key of your device, you must have physical access to your YubiKey.

#

###### [Master PIN](#master-pin-1)

If your local backup storage is a portable disk, similar to PC disk protection, to decrypt encryption key of your device, you must know your Master PIN.

If your local backup storage is a remote system (e.g. local server), then you will use your Hardware Security Module and Master PIN to authenticate to this remote system.

#

##### Special authentication methods for local backup storage

###### [Recovery key](#recovery-key)

This step is optional, but if you wish, you may generate a special recovery key which will be stored on your [Offline Backup Volume](#offline-backup-volume).

#

##### Attack vectors for local backup storage

###### [Compromising remote system acting as local backup storage](#compromising-remote-system-acting-as-local-backup-storage)

If you use local server as local backup storage, compromising this device will effectively give an attacker access to your backups and possibly data inside it.

#

###### [Compromising your machine which has access to your local backup storage](#compromising-your-machine-which-has-access-to-your-local-backup-storage)

If an attacker compromises your machine, either via software or by physical presence, they may access your local backup storage, which may give them access to data from your other devices.

#

#### Remote backup storage

With this guide, [BorgBackup](https://www.borgbackup.org/) is used for backups, but you may as well use [restic](https://restic.net/). Depending on the supported storage protocol you may favor one tool or another.

##### Regular authentication methods for Borg

###### [Hardware Security Module](#hardware-security-module)

As Borg performs remote backups over SSH protocol, access to backups will be authenticated the same way as backup to your server, which is, via GPG key stored on your YubiKey.

#

###### [Master PIN](#master-pin-2)

In addition to your YubiKey, which stores private key, Master PIN is needed to be able to use the PIN. This ensures, that even if someone steals your YubiKey, they won't be able to use it.

#

###### [Backup password](#backup-password)

In addition to authentication mechanism for accessing remote storage, backups are also protected with static password, which is used to protect encryption keys of your backups. This means even if an attacker get access to your storage, they won't be able to read your backups.

#

##### Special authentication methods for Borg

###### [Master GPG Key](#master-gpg-key)

If for any reason both your YubiKeys becomes unusable, you can still access your backups using copy of your authentication key in Master GPG keyring stored in [Offline Backup Volume](#offline-backup-volume).

#

###### [Deployment SSH Keys](#deployment-ssh-keys)

Depending on how you configure your remote server, you may have a special SSH key used only for configuring your server. If this is the case, make sure this SSH key is secure, as it will also allow accessing your backups.

#

##### Attack vectors for remote backup storage with Borg

Attack vectors for remote backup storage with Borg are omitted, as they would be too complex to be feasible. An attacker would need to bypass almost all of your security measures to get access to your backups, it would probably be easier to get access to your personal device instead.

### Summary

To summarize all describe attack vectors, here is the list of recommended best practices to follow:

- Never leave your devices unattended unlocked.
- If you leave your machine for longer period, hibernate it to remove disk encryption keys from memory.
- Do not use your Master Password or Master PIN on untrusted hardware.
- Keep your software up to date to protect it from known vulnerabilities.
- Use VPN service on your devices, especially when working in untrusted network environment (e.g. Hotels).

The list above lists behavior practices. Other best practices are more one-time, like:

- Using unique passwords with at least 256 bits of entropy.
- Using FIDO2 where possible.
- Using U2F where possible.
- Using GPG keys where possible.

## Requirements

This section describes what hardware/software is required to be able to make full use of this guide.

### Detailed list

Following hardware is required:

#### [1 x (or more) x86 Computer with UEFI support (and recommended Secure Boot and TPM support)](javascript:void(0);)

This guides assumes you have personal machine which will be used for daily operation.
The guide also supports customized installation for each machine if you have more than one.
The machine can be as well a virtual machine, though this is not recommended from security point of view, as host machine may not be trusted.

It is also helpful to actually have more than one machine available, so you can use other machine to help yourself with debugging if provisioning process of first machine fails for any reason.

```diff
- NOTE: Support for Secure Boot and TPM is highly recommended, without it your configuration will be less secure.
```



#

#### [1 x Temporary Computer running Linux, Windows or macOS](javascript:void(0);)

For bootstrapping process, this guide requires you to have a machine running modern OS, from which you will be able to create a bootable USB stick with Arch Linux ISO.

Target machine can be used as well so long you already have some operating system running on it.

#

#### [2 x Hardware security device with PIV, OpenPGP and OATH - HOTP support like ](javascript:void(0);)[YubiKey 5 Series](https://www.yubico.com/products/compare-yubikey-5-series/)

The main point of this guide is to make use of hardware security device as much as possible. Two devices are required so one can be kept in secure place as a backup in case the primary one is lost, stolen or damaged.

#

#### [2 x Dedicated removable storage device (e.g. pendrive) for offline backup of master keys and passwords](javascript:void(0);)

Some secrets generated as part of this guide (e.g. GPG master key) should be kept on always-offline volume to maximize their security.
To ensure redundancy for those volumes, it is recommended to have at least 2 copies of them, to be able to handle situation when one of them gets corrupted or simply breaks.
Those volumes may simply be encrypted pendrives.

#

#### [2 x Dedicated removable storage device (e.g. pendrive) for a OS recovery volume](javascript:void(0);)

This guide assumes data stored on daily computer is either version controlled, reproducible or regularly backed up into a local storage.
This means it should be possible and it is recommended to be able to re-install the OS on machine at any time in a timely manner.
To be able to do that, one should always keep a dedicated OS recovery volume, which is capable of performing fully automated OS installation.
Having this possibility allows not treating your workstation as [snowflake](#snowflake), giving you confidence, that when workstation breaks or gets stolen, you can quickly recover from it.

```diff
- NOTE: While 1 device should be sufficient for installation, it is recommended to have 2, so in case you have issues with new version of recovery volume, you can fallback to use the old one.
```



#

#### [1 x Temporary removable storage device (e.g. pendrive) for temporary storage](javascript:void(0);)

As part of bootstrapping process and in case of some incidents, it is recommended to have one storage devices from which can be formatted to be able to store files when rebooting machine from OS connected to the internet to offline mode.

#

#### [1 x Dedicated removable storage device (e.g. USB HDD, network disk) for local backups](javascript:void(0);)

Following [3-2-1 Backup Rule](#3-2-1-backup-rule) and to be able to quickly restore your last backup (restoring from local disk will be faster than restoring from internet), it is recommended to have a local storage available, which do not require internet access.

#

#### [1 x Dedicated remote storage server for remote backups (with SSH support for Borg or S3-like support for restic)](javascript:void(0);)

Again, following [3-2-1 Backup Rule](#3-2-1-backup-rule), to keep your backups geographically secure, it is recommended to have a remote storage server for keeping another copy of your backups, in case when both active copy and local backup gets damaged (e.g. in apartment fire).

#

### Summary

To summarize, following hardware is required for bootstrapping process:

- 1 x x86 machine currently running modern OS
- 2 x YubiKey 5 Series
- 5 x 8GB+ pendrive (2 x backup + 2 x recovery + 1 x temporary)

And additionally for day-2 operations:

- 1 x Dedicated removable local storage device
- 1 x Dedicated remote storage with either SSH or S3-like support

## Bootstrapping

This section explains steps, which needs to be performed once to start using practices defined in this guide.
It includes tasks like generating [GPG Master Key](#gpg-master-key), creating [Master Password](#master-password), generating [Secure Boot Platform Key (PK)](#secure-boot-platform-key-pk) etc.

At the end of this section, you will have:
- The following secrets generated and backed up on 2 encrypted pendrives:
  - Master Password
  - PIN
  - GPG AdminPIN
  - PIV PUK
  - YubiKey Challenge-Response secret
  - Secure Boot Platform Key (PK)
  - Secure Boot Key Encryption Key (KEK)
  - (Optional) Password salt
- Both YubiKeys initialized with:
  - Signing key (DB) for Secure Boot via PIV applet.
  - GPG signing, encryption and authentication sub-keys via OpenPGP applet.
  - Challenge-Response on 2nd slot.
- Recovery USB stick with personalized Arch Linux installer.

### Preparation

Before we start creating secrets etc, we must prepare some dependencies which will be needed later. Follow the steps below.

#### Getting Arch Linux installation medium

First step of bootstrapping is to get a Arch Linux USB Stick created. We will use it without network configured for secrets generation.

For this step, following items are required from [Requirements](#requirements) section:
- 1 x Temporary removable storage device (e.g. pendrive)
- 1 x Temporary computer running Windows, Linux or macOS

With items above prepared, head to [USB flash installation medium](https://wiki.archlinux.org/index.php/USB_flash_installation_medium) and prepare your USB stick.

Before rebooting, make sure you remember an address of this guide, so you can continue following it there.

Once rebooted, make sure you configure your network before proceeding.

##### Configuring Arch Linux ISO

###### Connecting to the Wi-Fi

If you know the name of your device and your network SSID, you can use the command below to authenticate to the network. Once done, connection should be established automatically and DHCP client should configure the rest automatically.

```sh
iwctl station <device> connect <ssid>
```

To find your wireless device names, run:

```sh
iwctl device list
```

To scan and list available networks, run:

```sh
iwctl station <device> scan && iwctl station <device> get-networks
```

###### Expanding available disk space

To make some space if you need to install more packages, run the following command:

```
mount -o remount,size=4G /run/archiso/cowspace
```

NOTE: All packages will be installed into RAM, so make sure you have enough of it available. Depending on the age of your ISO, you may also need to install updates to make things working.

NOTE: 4GB should be sufficient to install all updates, Gnome Shell and Firefox.

###### Installing and running graphical interface

If you want to have a graphical interface during bootstrapping, run the following commands:

```sh
pacman -Syyu gnome-shell gnome-terminal
XDG_SESSION_TYPE=wayland dbus-run-session gnome-session
```

NOTE: This is only required to be done manually during bootstrapping process. Later on, your customized ISO may have it included out of the box.

#### Fetching required resources into temporary volume

With Arch Linux USB stick running, we can fetch this repository, verify it's signature and run a script, which will pull all required dependencies into a temporary volume, so you can continue following bootstrapping process without the internet access, to make sure generated secrets are not exposed to the internet.

##### Format and mount temporary volume

Once running Arch, plug your temporary volume, format it if needed and mount it somewhere. Then make it your working directory.

##### Fetching repository

Run the following command to import GPG signing public key, which is used to sign releases in this repository.
This will allow to verify the signature of downloaded code.

```sh
curl https://github.com/invidian.gpg | gpg --import
```

Then, run the commands below to fetch and verify this repository:

```sh
VERSION=testing
curl -L https://github.com/invidian/secure-and-reproducible-arch-linux/releases/download/${VERSION}/${VERSION}.tar.gz.asc -o ${VERSION}.tar.gz.asc
curl -L https://github.com/invidian/secure-and-reproducible-arch-linux/archive/${VERSION}.tar.gz -o ${VERSION}.tar.gz
gpg --verify ${VERSION}.tar.gz.asc ${VERSION}.tar.gz
```

If everything worked, you should see the output similar to the following:
```console
gpg: Signature made Fri Jan 22 23:22:10 2021 UTC
gpg:                using RSA key C79F76DAB29245AE262EC790CEBABB44587E3AE2
gpg: Good signature from "Mateusz Gozdek <mgozdekof@gmail.com>" [unknown]
```

The output will also include the following:
```console
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 297C 1601 AF63 2225 7066  7925 9718 7FA1 271E C224
     Subkey fingerprint: C79F 76DA B292 45AE 262E  C790 CEBA BB44 587E 3AE2
```

Despite this warning, the repository you downloaded is still correct according to the signing key that you downloaded.

To learn more about this warning, read [Tails documentation about verifying images](https://tails.boum.org/install/download/index.en.html#command-line).

##### Fetching dependencies

Use Terminal opened in previous step or make sure you're in the temporary volume as a working directly and run the following commands to download the packages, which we will install once we go into offline mode.

```sh
pacman -S hopenpgp-tools yubikey-personalization yubikey-manager sssd git
mkdir packages
cp /var/cache/pacman/pkg/* ./packages/
echo "TODO: Get 'yubico-piv-tool' tool!" && exit 1
```
Next, download hardended GPG configuration we will use when generating GPG keys:
```sh
curl https://raw.githubusercontent.com/drduh/config/master/gpg.conf -o gpg.conf
```

#### Rebooting into offline mode

With all dependencies from the internet pulled, we can now reboot to make sure our OS has not been tampered and to make sure we stay in offline mode.

##### Ensure you will be offline

Before you boot, ensure your Ethernet cable is unplugged to make sure you don't get network configured automatically.

##### Mounting temporary volume

After the reboot, mount the temporary volume, unpack this repository and continue following the instruction.

##### Installing dependencies offline

Open terminal with temporary volume as your working directory, then run the command below to install all required packages:

```sh
pacman -U ./packages/*
```

### Creating secrets

Now we can proceed with the secrets generation.

#### Master Password

First thing to do is to create and memorize your personal [Master Password](#master-password). It will be used to protect your [Daily Password Manager](#daily-password-manager) and to decrypt [Offline Backup Volumes](#offline-backup-volume) and this is the only password you will have to remember.

This password should never be written down or saved to minimize the risk of it leaking.

##### Recovery

###### Sharding

It is recommended to prepare for a situation, where you cannot remember the Master Password anymore or if anything happens to you, your family is able to get access to your data on your behalf.

To do that securely, this guide recommends using [Shamir's Secret Sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing) implemented with `ssss` CLI tool, which allows you to split your Master Password into 3 or 5 shares, which you can then distribute across your trusted family members, friends, lawyer or a bank. Only after gathering the majority of the shares, one will be able to reveal your Master Password.

While Shamir's Secret Sharing has mixed opinions in terms of security and in certain scenarios it might be insecure, for such a rare use as recovery of the Master Password, it should be sufficient.

You can generate your shares using the following command:

```sh
ssss-split -t 3 -n 5 -w your-name-master-password
```

Once you type your Master Password, it will print you 5 shares line by line, which you should securely distribute to your trusted family members, friends, lawyer or a bank.

###### Distribution

When sharing the shards with trusted parties, assume they may not be as technical as you, so make it clear what is a document you give them, under what conditions it should be used and how to use it. It may also include a list of all the parties who posses a shard to make a recovery process easier.

###### Periodic verification

Periodically, for example annually, you should verify with all the parties, that they still have access to their shards and that their contact information is actual. This is recommended to avoid situation, where in case of a need for recovery, you find out that majority of the shards is lost or certain parties are not reachable anymore.

###### Rotating Master Password

In case when you need to change your Master Password, all shards must be re-generated and re-distributed to all parties. Old shards should be destroyed in such scenario.

###### Combining shards

You can test the recovery process by executing the following command:

```sh
ssss-combine -t 3 -n 5
```

Now, provide 3 of 5 shards. As a result, you should see your Master Password being printed.

#### Backup volumes

##### Identifying plugged devices

With your new Master Password, plug your USB devices which will serve as a [Offline Backup Volumes](#offline-backup-volume), then use the command below to identify plugged devices:

```sh
ls -d /dev/disk/by-id/* | grep -v -E -- '(-part[0-9]+|by-id/(dm|lvm|wwn|nvme-eui)-)'
```

If you are unsure, which of your device is which, in care of removable devices, you can run the following command:

```sh
journalctl -fk | grep 'SerialNumber:'
```

Then unplug and plug your device. It should print you the serial number, which you can find in the list created by the command above.

##### Formatting

Once you identified your device, run the following command to make be able to automate remaining commands:

```sh
export OBV_DEVICE=<your full to device>
export OBV_ID=OBV1 # Paritition label is limited to N characters.
```

Now, run the command below to examine the script which will create a new GPT partition table on your selected device and create one big partition on it:

```sh
cat ./scripts/partition-offline-backup-volume.sh
```

Once you confirm, that the script is safe to run, run it:

```sh
./scripts/partition-offline-backup-volume.sh
```

Now, let's create a LUKS container on partition we created using the command below:

```sh
export PARTITION=/dev/disk/by-partlabel/$OBV_ID
test -b $PARTITION && \
  cryptsetup luksFormat --verbose --verify-passphrase --label $OBV_ID $PARTITION
```

Now we need to open created LUKS container to create a filesystem on it. This can be done with the command below:

```sh
cryptsetup open $PARTITION $OBV_ID
```

Now, create a `ext4` filesystem using the following command:

```sh
export DEVICE=/dev/mapper/$OBV_ID
test -b $DEVICE && mkfs.ext4 -L $OBV_ID $DEVICE
```

And now mount it:

```sh
export MOUNTPOINT=/mnt/$OBV_ID
mkdir -p $MOUNTPOINT && mount $DEVICE $MOUNTPOINT
```

Now, you can repeat the steps above for your another recovery device.

##### Safe removal

To remove your device safely before unplugging, run the following commands:

```sh
sync && \
umount /mnt/$OBV_ID && \
rmdir /mnt/$OBV_ID && \
cryptsetup close /dev/mapper/$OBV_ID
```

##### Mounting secure volume again

If you want to make your Offline Backup Volume available again, run the following commands to identify the right device:

```sh
ls -d /dev/disk/by-id/* | grep -v -E -- '(-part[0-9]+|by-id/(dm|lvm|wwn|nvme-eui)-)'
journalctl -fk | grep 'SerialNumber:'
```

Now plug the device and export information about it:

```sh
export OBV_DEVICE=<your full to device>
export OBV_ID=OBV1
```

And run commands below to decrypt and mount it:

```sh
export PARTITION=/dev/disk/by-partlabel/$OBV_ID
cryptsetup open $PARTITION $OBV_ID
export MOUNTPOINT=/mnt/$OBV_ID
mkdir -p $MOUNTPOINT && mount /dev/mapper/$OBV_ID $MOUNTPOINT
```

##### Initializing

This guide use `git` to version content on your Offline Backup Volume. This allows:

- Easy synchronization between multiple copies of Offline Backup Volume.
- Versioning of generated secrets.
- Improved integrity with Git checksums.

##### Summary

When you are finished, leave at least one device plugged, decrypted, mounted and make it your working directory, so we can save some files there.

#### Master PIN

Similar to Master Password, you should create and memorize digits-only PIN number, which will be used while performing actions with your YubiKey. Similar to Master Password, this PIN number should never be written down or typed on insecure machines.

PIN will be used for:

- GPG Smartcard functionality
- FIDO2 access

#### Configuring YubiKeys

##### Setting up HMAC-SHA1 Challenge-Response

###### Generating access code

From https://security.stackexchange.com/a/183951

```sh
(LC_ALL=C tr -dc '[:digit:]' < /dev/urandom | head -c12; echo) > yubikey-slot-2-hmac-sha1-challenge-response-access-code
```

###### Generating configuration

TODO:

- Breakdown flags here, from https://developers.yubico.com/yubico-pam/Authentication_Using_Challenge-Response.html

```sh
ykpersonalize -d -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible -oaccess=$(cat yubikey-slot-2-hmac-sha1-challenge-response-access-code) -c000000000000 -s yubikey-slot-2-hmac-sha1-challenge-response-configuration
```

###### Writing configuration to devices

With configuration generated, plug each of your YubiKey and run the following command to apply generated configuration:

```sh
cat yubikey-slot-2-hmac-sha1-challenge-response-configuration | ykpersonalize -d -2 -c000000000000
```

##### Setting up PIV applet

From https://developers.yubico.com/yubico-piv-tool/YubiKey_PIV_introduction.html

###### Generating management key

```sh
export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -d '[:lower:]' | tr -cd '[:xdigit:]' | fold -w48 | head -1 > yubikey-piv-applet-management-key
```

###### Generating PUK

```sh
export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -cd '[:digit:]' | fold -w6 | head -1 > yubikey-piv-applet-puk
```

###### Setting PIN

```sh
yubico-piv-tool -achange-pin -P123456
```

##### Setting up GPG smartcard

###### Setting Admin PIN

To generate:

```sh
export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -cd '[:digit:]' | fold -w6 | head -1 > yubikey-gpg-smartcard-admin-pin
```

To configure PIN and Admin PIN, run the following command:

```sh
gpg --card-edit
```

#### Generating GPG keys

##### Prepare GPG configuration

Open Terminal and change working directory to one of Offline Backup Volumes. Then run the following commands:
```sh
export GNUPGHOME=$(pwd)/gnupg-workspace
mkdir -p "$GNUPGHOME"
chmod 0700 "$GNUPGHOME"
```

Now, copy previously downloaded `gpg.conf` file into new GPG home directory by running command like:
```sh
cp <path to temporary volume>/gpg.conf "$GNUPGHOME/"
```

##### Generate keys

##### Transfering keys into YubiKeys

#### Generating Secure Boot keys

##### Transferring Database Key into YubiKeys

#### Creating Arch Linux bootable USB device

With downloaded and verified Arch Linux ISO, you can now plug your USB device which you would like to use as an [OS Recovery Volume](#os-recovery-volume). For now we will write vanilla Arch Linux ISO on it to be able to create a customized version of it.

For simplicity, you can again use `Utilities -> Disks` application on Tails, select the right device, then open menu and select "Restore Disk Image" option there.

After successful disk restoration, you can unplug this USB device for now, we will need it at latest stage.

#### Q&A List

- How do you boot Secure OS with Secure Boot enabled?
  - You don't. You boot Recovery OS instead.
    - Guarantees **Authenticity (identity)**.
- How do you protect booting Recovery OS? Does it need to be protected?
  - You can use `dm-verity` to generate hash of root filesystem, then add it to the kernel command line parameters with EFISTUB and sign it using Secure Boot Database Key.
    - Guarantees **integrity**.
  - What about possible credentials stored on the image? Private keys for Wireguard installation network? WiFi password? If you encrypt, how do you decrypt?
    - There should be no secrets stored on the image except the WiFi password, which is required to enable installation over local wireless network. An attacker with physical access to your Recovery Image, may have physical access to your Ethernet network anyway, if you do not have 802.1X configured on Ethernet level or additional physical protection on the Ethernet ports.
      - Limiting/disabling DHCP does not offer any real security.
      - MAC address filtering does not offer good security either, as MAC addresses can be spoofed. It may also be difficult to roll out on some devices.
      - Security measures should be used on higher levels than MAC addresses (Layer 2) anyway to provide additional security for your network.
    - Storing other types of secrets in Recovery Image is not supported right now with this guide. If this is what you really need, perhaps you need to replace the `archiso` in Recovery Image build process to perform regular Arch Linux installation, including disk encryption, similar to what we will be finally using, then configuring `overlayfs` combined with `tmpfs` or similar configuration and mount your root partition in read-only mode, to get ISO like environment which cannot be permanently modified while used.

## Day-2 Operations

This section documents various processes, which are needed in daily use, like [Updating Kernel](#updating-kernel), [OS Installation](#os-installation) or handling [Lost YubiKey](#lost-yubikey).

### Machine Maintenance

#### Booting up

#### OS Installation

#### Updating system configuration and rebuilding Recovery ISO image

#### Updating Kernel

#### Updating BIOS

#### Bootstrapping new hardware


### YubiKey Maintenance

#### Adding new OATH-TOTP secret

#### Provisioning new YubiKey

#### Unlocking locked Master PIN


### Using Offline Backup Volume

After initial bootstrapping, the following information is stored on your Offline Backup Volume:
- GPG Master Key
- Secure Boot Platform Key
- Secure Boot Key Encryption Key

#### Accessing

#### Signing someone else's GPG key

#### Storing MFA recovery tokens

When you register to new service where you use MFA and service generates recovery tokens for you, follow the following procedure:

- Encrypt file containing recovery tokens using GPG with you as an recipient
- Ensure you can decrypt encrypted data
- Remove original file with plain-text recovery tokens
- Transfer encrypted recovery tokens on temporary volume
- Boot up Offline Recovery Volume
- Plug in both of your Offline Backup Volume and access them
- Store recovery tokens on both Offline Backup Volumes, either encrypted or decrypted

#### Extending expiry time of your GPG keys

#### Rotating Master Password

### Incident responses

#### Compromised Daily Password Manager copy

#### Compromised Daily Password Manager content

#### Compromised Offline Backup Volume

#### Compromised machine running unauthorized code

#### Compromised Master Password

#### Compromised Master PIN

#### Destroyed single Offline Backup Volume

#### Destroyed both Offline Backup Volumes

If both of your Offline Backup Volumes gets destroyed...

#### Destroyed single YubiKey

If one of your YubiKeys gets stolen or destroyed...

#### Destroyed all YubiKeys

If all your YubiKeys gets stolen or destroyed...

#### Destroyed Disk encryption header

If you damage your disk encryption header, e.g. using `dd` writing to your encrypted partition...

#### Destroyed Disk encryption key

If you remove your disk encryption key from boot partition...

#### Destroyed TPM Secret

If your machine gets damaged OR you accidentally wipe your TPM Secret...

#### Revoking your GPG sub-keys

#### Restoring your Master Password from shards

#### A password gets compromised

## Miscellaneous

This section contains useful information and notes not mentioned in the sections above.

### Trying out this guide in virtualized environment

You can try out most of the best practices described in this guide in virtualized environment e.g. using QEMU.

Here is the breakdown of supported features:

- QEMU supports UEFI boot with Secure Boot via OVMF.
- QEMU supports emulating both TPM 1.2 and TPM 2 via [tpm2-tss](https://github.com/tpm2-software/tpm2-tss)
- Emulation of YubiKey PIV applet is currently not supported. As an alternative, you can either:
  - Do USB pass-through of your real YubiKey device to the virtual machine and use some unused slots for testing. YubiKey has 24 slots for certificates available, this guide uses only one for Secure Boot DB key pair.
  - Use [tpm2-pkcs11](https://github.com/tpm2-software/tpm2-pkcs11) as a backend for PKCS#11 engine used by `sbsign`.
- Emulation of YubiKey GPG smartcard applet is currently not supported either. For testing, you can:
  - Do USB pass-through of your real YubiKey device to the virtual machine. This guide use all 3 GPG slots on YubiKey, so make sure you have a backup of your existing keys.
  - Create a virtual disk which will be acting as your portable GPG keyring. Minimal extra steps will be required to get it to work, e.g. making sure virtual disk is mounted at time when GPG is required + additional environment variable to point to the right `$GNUPGHOME`.

### Block-based backups vs File-based backups

This guide prefers file-based backups

### Credentials which shouldn't be stored in [Daily Password Manager](#daily-password-manager)

This section contains list of credentials which are recommended to not be stored in [Daily Password Manager](#daily-password-manager),
as storing them there may have security implications if password manager gets compromised.

#### [MFA Recovery Codes/Tokens](javascript:void(0);)

It is not recommended to keep MFA Recovery Codes in your Daily Password Manager, because if content of your Daily Password Manager leaks, it allows an attacker to bypass the requirement of your YubiKey to log in into 2FA enabled services. See [Storing MFA recovery tokens](#storing-mfa-recovery-tokens) section to learn how to safely store MFA Recovery Tokens.

#

#### [Password Salt](javascript:void(0);)

If you add "salt" to passwords stored in Daily Password Manager for extra security, make sure the salt is not stored there too. This also applies when you re-use salt for some other purposes e.g. as a PIN for GPG/PIV.

#

#### [API Keys for services with MFA enabled](javascript:void(0);)

If you protect access to certain service using MFA, but you store API keys with full privileges in your Daily Password Manager, this effectively breaks the purpose of using MFA, as obtaining the API key will effectively give an attacker full access to the service.

#

#### [Private keys](javascript:void(0);)

Whenever possible, Hardware Security Module should be used to store your private keys instead of Daily Password Manager. As an alternative, you may also use TPM to safely store your private keys. You can generate them using Offline Recovery Volume and then transfer to any machine where you are going to need them.

#

#### [Master Password and Master PIN](javascript:void(0);)

Considering, that this information should never be digitally saved, it is best practice to not put those in your Password Manager either.

This allows to treat those authorization factors really as "something you know".

#

#### [GPG AdminPIN and PIV PUK](javascript:void(0);)

If one has access to your GPG AdminPIN or PIV PUK, they can try to brute-force your PIN and they may modify settings on your smartcard in case GPG AdminPIN.

Also, if your Password Manager gets compromised (e.g. you leave unlocked machine with unlocked password manager), having a PUK or AdminPIN allows an evil actor
to change the PIN on your security token, which effectively gives them access to your security token.

However, if you lock your YubiKey by entering wrong PIN multiple times, the only way to unlock it is when you get access to your Offline Backup Volume, which might not be very convenient.

#

#### Disk encryption recovery keys

Similar to situation with GPG AdminPIN and PIV PUK, storing Disk encryption recovery keys in your Daily Password Manager trades security for convenience. If an attacker compromises your Daily Password Manager (e.g. you leave unlocked machine with unlocked password manager), then they can look up your disk encryption recovery keys for other devices and get access on them later.

In the real-world scenario, you will need recovery keys in the following situation:

- Accidental BIOS update - If you update your BIOS without suspending the TPM requirement for disk encryption, then after the update your system will refuse to decrypt due to differences in PCR values in TPM.
- Accessing data on another device - If your device gets damaged and you wish to access your data using e.g. USB adapter, then the only way to decrypt the disk is using recovery key.
- Accessing data from insecure OS - If you wish to access your data from e.g. bootable USB device which is not Secure Boot signed for your machine, then you must use the recovery key.

NOTE: The recovery key should be at least 55 uppercase, lowercase and number characters long to provide enough entropy against brute-force attacks, which might be a trouble for type by hand sometimes, though from my experience it's doable. If not, see [Old Android phone as Offline Password Manager](#old-android-phone-as-offline-password-manager).

#

#### TPM Passwords

Depending on TPM version on your hardware, you will either need to manage one or more passwords to configure TPM on each of your devices.

For TPM1.2, there is only single owner password which is required for all TPM operations.

With TPM 2.0, each hierarchy (group of objects) can be managed using separate password. This guide only stores few secrets in TPM.

### Credentials which can be stored in [Daily Password Manager](#daily-password-manager)

Depending on your preference, here are the credentials, which you probably can store in your Daily Password Manager and it shouldn't in a significant way
degrade your level of security.

#### [BIOS Password](javascript:void(0);)

If an attacker has access to your machine, they may try to replace your `initramfs` with malicious one. However, Secure Boot protects against such scenario, as UEFI will refuse to boot unsigned `initramfs` as long as Secure Boot is enabled.

If an attacker has both access to your machine and manages to bypass the BIOS password, they can disable Secure Boot and let their `initramfs` execute when you boot the machine again. This will allow them to hide from you, that Secure Boot has been disabled, which will allow them to obtain your Master PIN, as this is what you type into the machine when decrypting the hard drive.

To protect against compromised BIOS, [tpm2-totp](https://github.com/tpm2-software/tpm2-totp) project is used, which will generate TOTP code using secret stored in TPM and will display it on encryption password prompt while booting. It is then user's responsibility to verify the code using other device.

The secret for `tpm2-totp` will be sealed against TPM PCR bank 7, which stores hash of the current state of Secure Boot configuration. If you replace any of Secure Boot keys like KEK or PK, the value will change, so you won't be able to generate valid TOTP code anymore. This means, if attacker replaces your Secure Boot keys with yours, you will notice that, as boot process won't be able to calculate valid TOTP code anymore.

#

### Why Secure Boot keys do not require periodic rotation

Even though Secure Boot use X.509 certificates, it's doing so to be able to identify certificates using UUID and to attach additional metadata to the certificates using e.g. `CommonName` field.

Validity time fields are not used by Secure Boot implementations.

In addition to that:

- Both PK and KEK private keys are kept offline, so they compromise risk is greatly limited.
- When encrypting data is transported over insecure medium (e.g. Internet, WiFi), it is recommended to periodically rotate the encryption keys, so if attacker listening and recording the transmission manages to break the encryption key, they will only be able to access part of the transported data.
- Signature private key is stored on Hardware Security Module, which eliminates the risk of private key being stolen.

### Why does Secure Boot keys do not require respecting expiry time

BIOS clock might be tampered (changed or reset), which would make Secure Boot to always fail, or BIOS clock can be corrected to always allow of use old Secure Boot keys. So to summarize, as clock cannot be trusted, it does not provide any real security, so it is ignored.

### Technology used by this guide

- TPM2 TOTP - To assert the unalteredness and trustworthiness of your device.
- Secure Boot - To prevent injecting and executing malicious code on your device at the bootloader/initramfs level.

### What this guide does not protect from

This guide is designed to provide high level of security to rather low-profile people, which most likely won't be targeted by some organizations, so this section gives couple of examples in which scenarios this guide most likely won't provide sufficient security.

#### Operating on compromised machine

Considering the following facts:
- Most likely Linux desktop machines are not a common target for malware.
- Minimizing the damage from operating on a compromised machine is very inconvenient.
- On a desktop machine, user data is most likely more valuable than system data.

This guide only slightly reduces the damage in situation, where your machine gets compromised.

Assuming that your machine gets compromised (e.g. via RCE vulnerability + privilege escalation),
the following things happen:

- All unencrypted data stored on this machine should be considered public.
- All online services which do not use MFA should be considered compromised.
- All online services which active sessions you have opened on your machine (browser, API keys etc),
  should be considered compromised.
- Your Master Password and Master PIN are most likely compromised, as attacker can record your keystrokes.
- Other systems where your machine has unattended access (e.g. Kubernetes clusters).

Following information remains safe:
- Your GPG identity, as it is protected by physical touch.
- All online services which you do not have active sessions opened.

#### Apartment theft

If one breaks in into your apartment, ties you up and beats you up until you reveal your credentials to them,
this guide most likely won't help you.

### AES-256 security

In this guide, following data volumes are protected by Master Password:

- Daily Password Manager
- Offline Backup Volume

Compromising any of this data volumes allows attacker to perform an offline attack on them, to eventually get access
to the information inside.

The time window to successfully attack such encrypted volume is a time where information inside is still considered safe.
However, you may not know that the encrypted volume has leaked or you don't know what information an attacker already have.
For instance, an attacker may already have some idea what form your Master Password is, which reduces the attack window. Or an attacker may try to trick you to leak your Master Password, for example by using hardware keylogger.

If those volumes were not encrypted, attacker would have access to information inside immediately (in 0 time).

In this case, both data volumes are encrypted using AES-256. Assuming that the password has high enough entropy (AES-256 use 256 bits keys,
so password should have at least 256 bits of entropy), the data should be considered safe from brute-force attacks, even if you consider growing
computing power efficiency (doubles over ~3-5 years, so complexity decreases from 2^256 to 2^255 over ~3-5 years), raise of quantum computing (initial
algorithms can reduce required computation complexity by half, so from 2^256 to 2^128) etc.

In case of KeepassXC, which use HMAC-SHA1 slot in YubiKey, it generates additional ~150-170 bits of entropy added to your password, which is protected by hardware key.

During time window, where attacker can try to brute-force the password, it is recommended to rotate all your secrets stored on the volumes listed above, so when an attacker
finally cracks them, they will no longer be useful. However, as time window size in such circumstances is enormously long, *not* rotating your secrets *should* not have an impact on your security.

### Old Android phone as Offline Password Manager

[Credentials which shouldn't be stored in Daily Password Manager](#credentials-which-shouldnt-be-stored-in-daily-password-manager) section highlighted which credentials shouldn't be stored in your Daily Password Manager from safety reasons. The only way to access those secrets is to boot Offline Recovery Volume, plug your Offline Backup Volume and get password from there. This might be not very convenient if you have limited number of devices available.

As an alternative for Offline Recovery Volume, you may consider using old Android phone without network configured and without SIM card as a simple offline password manager, which would have additional copy of your passwords you keep offline, protected by the same Master Password which is used to protect Offline Backup Volume. This should make it more convenient to access passwords stored there when needed.

You could even try and modify your Android phone to act as a USB keyboard or use device like [InputStick](http://inputstick.com/) to avoid typing your password yourself.

## Glossary

### [Daily Password Manager](#daily-password-manager)

Password manager, which you use for every day logging in on your end devices like laptop or smartphone. This guide use KeePassXC, as it supports YubiKeys as a factor for unlocking the password database.

#

### [Offline Password Manager](#offline-password-manager)

Password manager, stored on encrypted volume, which you only access from Live USB, which has no internet connection. It holds all critical credentials, which are not required during daily operation like AdminPIN, PUK, YubiKey PIV ManagementKey, Secure Boot Platform Key etc.

#

### [3-2-1 Backup Rule](#3-2-1-backup-rule)

Backup rule saying you should always have at least **3** copies of your data, store **2** backup copies on different devices or storage media and keep at least **1** backup copy off-site.

#

### [Snowflake](#snowflake)

Snowflake is servers/machines, which configuration has drifted from original or automated configuration. Such drift is not desired, as configuration of such machines are hard to reproduce, which makes the recovery process harder when machine breaks.

#

### [Offline Recovery Volume](#offline-recovery-volume)

Recovery volume booted without network support.

#

### [GPG Master Key](#gpg-master-key)

GPG Master Key is a main source of trust for your GPG identity.
This key has only signing capabilities, it is used only to sign and revoke your [GPG sub-keys](#gpg-sub-keys) and it should only be stored on offline volumes to minimize the risk of leaking.

#

### [GPG Sub-keys](#gpg-sub-keys)

GPG keys which are used on a daily basis. Usually it is a signing key, encryption key and authentication key. All 3 keys should be stored on Hardware security device.

#

### [Master Password](#master-password)

Master password is the only password you must remember when following this guide.
This password is used for unlocking your daily password manager and to decrypt [Offline Backup Volumes](#offline-backup-volume).
This password should be long and complex to make sure it cannot be brute-forced.

#

### [Offline Backup Volume](#offline-backup-volume)

Offline Backup Volume is a local storage device (e.g. Pendrive), encrypted using [Master Password](#master-password), which contains all secrets like [GPG Master Key](#gpg-master-key), which must be kept secure at all cost.
Accessing it's data should only be performed from [Offline Recovery Volume](#offline-recovery-volume) with no network access.

#

### [Secure Boot Platform Key (PK)](#secure-boot-platform-key-pk)

Top level X.509 certificate with RSA key-pair used in Secure Boot process.
"Platform" in "Platform Key" refers to a [Computing platform](https://en.wikipedia.org/wiki/Computing_platform), which can be
an actual piece of hardware you execute code on, but can also be a visualized environment or a web browser.

Owning Platform Private Key allows you to proof to the UEFI that you are the physical owner of the hardware.

This trust is established by requiring physical presence to the unit (platform) to "take ownership", so to add initial PK.

If the attacker posses the Platform Private Key and access to the hardware, it does not give them direct access to execute code on the platform, as one needs to execute code, which will add a malicious public key to the signature database.

Usually this key is populated with device manufacturer (OEM) key and it signs KEK keys, including Microsoft CA.

This guide assumes that you are platform owner, so as part of [Bootstrapping](#bootstrapping) process you will generate and roll your own Platform Key, which will later be stored on [Offline Backup Volume](#offline-backup-volume), as it is not required for daily operation.

#

### [OS Recovery Volume](#os-recovery-volume)

Removable device, which contains your personalized Arch Linux installer.

#

### [MFA/2FA - Multi/Two Factor Authentication](#mfa-2fa-multi-two-factor-authentication)



#

### [MFA Recovery Token](#mfa-recovery)



#
