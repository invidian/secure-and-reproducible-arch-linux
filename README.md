# Secure and reproducible Arch Linux

## Introduction

### Goals

This guide has the following goals:
- Automate secure installation of Arch Linux.
- Document security best practices and processes around performing backups, using YubiKeys, operating Secure Boot etc. in a single place.
- Provide optimal security against unauthorized access to online services you use.
- Provide optimal security against unauthorized access to data on your devices.

### Audience

This guide is mainly targets developers and system administrators using Linux as daily operating system on their workstations, which either use or would like to use Arch Linux.

### Motivation

The main motivation for this project is to gather and combine various best practices

## Table of Contents

- [Secure and reproducible Arch Linux](#secure-and-reproducible-arch-linux)
  * [Introduction](#introduction)
    + [Goals](#goals)
    + [Audience](#audience)
    + [Motivation](#motivation)
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
      - [Configuring Arch Linux ISO](#configuring-arch-linux-iso)
        * [Connecting to the Wi-Fi](#connecting-to-the-wi-fi)
        * [Expanding available disk space](#expanding-available-disk-space)
        * [(Optional) Installing and running graphical interface](#optional-installing-and-running-graphical-interface)
      - [Fetching required resources into temporary volume](#fetching-required-resources-into-temporary-volume)
        * [(Optional) Format temporary volume](#optional-format-temporary-volume)
        * [Mount temporary volume](#mount-temporary-volume)
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
          + [Swapping slots](#swapping-slots)
          + [Checking existing Challenge-Response configuration](#checking-existing-challenge-response-configuration)
          + [Generating Access Code](#generating-access-code)
          + [Configuring access code](#configuring-access-code)
          + [Verifying access code](#verifying-access-code)
          + [Generating Challenge-Response key](#generating-challenge-response-key)
          + [Setting Challenge-Response key on the devices](#setting-challenge-response-key-on-the-devices)
          + [Verifying Challenge-Response configuration](#verifying-challenge-response-configuration)
          + [hmac-lt64 configuration flag](#hmac-lt64-configuration-flag)
        * [Setting up PIV applet](#setting-up-piv-applet)
          + [Generating Management Key](#generating-management-key)
          + [Configuring Management Key](#configuring-management-key)
          + [Generating PUK](#generating-puk)
          + [Setting PUK](#setting-puk)
          + [Setting PIN](#setting-pin)
          + [Summary](#summary-3)
        * [Setting up OpenPGP applet](#setting-up-openpgp-applet)
          + [Setting Admin PIN](#setting-admin-pin)
          + [Setting PIN](#setting-pin-1)
          + [Setting Reset Code](#setting-reset-code)
        * [Configuring and securing other YubiKey applets](#configuring-and-securing-other-yubikey-applets)
      - [Generating GPG keys](#generating-gpg-keys)
        * [Prepare GPG configuration](#prepare-gpg-configuration)
        * [Generate keys](#generate-keys)
          + [Generating Master Key](#generating-master-key)
          + [(Optional) Adding extra identities to your Master Key](#optional-adding-extra-identities-to-your-master-key)
          + [Generating Signing key](#generating-signing-key)
          + [Generating Encryption key](#generating-encryption-key)
          + [Generating Authentication Key](#generating-authentication-key)
          + [(Optional) Signing new Master Key with your existing key](#optional-signing-new-master-key-with-your-existing-key)
      - [Generating Secure Boot keys](#generating-secure-boot-keys)
        * [Checking if YubiKey PIV slot is in use](#checking-if-yubikey-piv-slot-is-in-use)
          + [Checking if YubiKey PIV slot has certificate](#checking-if-yubikey-piv-slot-has-certificate)
          + [Checking if YubiKey PIV slot has key pair](#checking-if-yubikey-piv-slot-has-key-pair)
        * [Generating Platform Key (PK) and Key Exchange Key (KEK)](#generating-platform-key-pk-and-key-exchange-key-kek)
        * [Transferring Database Key into YubiKeys](#transferring-database-key-into-yubikeys)
        * [Verifying signing capabilities](#verifying-signing-capabilities)
      - [(Optional) Generating Password Salt](#optional-generating-password-salt)
      - [Generating secrets for your first hardware](#generating-secrets-for-your-first-hardware)
    + [Saving and synchronizing data between Offline Backup Volumes](#saving-and-synchronizing-data-between-offline-backup-volumes)
      - [Configuring Git](#configuring-git)
      - [Initializing repository](#initializing-repository)
      - [Initial sync into other Offline Backup Volumes](#initial-sync-into-other-offline-backup-volumes)
      - [Syncing further changes](#syncing-further-changes)
    + [Transferring GPG keys into YubiKeys](#transferring-gpg-keys-into-yubikeys)
    + [Copying public keys and certificates into Temporary Volume](#copying-public-keys-and-certificates-into-temporary-volume)
    + [Creating first Arch Linux bootable USB device](#creating-first-arch-linux-bootable-usb-device)
      - [Customizing your Arch Linux ISO profile](#customizing-your-arch-linux-iso-profile)
        * [Network setup](#network-setup)
        * [SSH Access](#ssh-access)
        * [GUI](#gui)
      - [Saving your Arch Linux ISO profile](#saving-your-arch-linux-iso-profile)
      - [Writing your Arch Linux ISO into Recovery Volume](#writing-your-arch-linux-iso-into-recovery-volume)
    + [Summary](#summary-4)
  * [Hardware Bootstrapping](#hardware-bootstrapping)
    + [Generating hardware secrets](#generating-hardware-secrets)
      - [Booting Recovery Volume in Offline mode](#booting-recovery-volume-in-offline-mode)
      - [Mounting Offline Backup Volume](#mounting-offline-backup-volume)
      - [Selecting hardware hostname](#selecting-hardware-hostname)
      - [Generate Disk Encryption Recovery Key](#generate-disk-encryption-recovery-key)
      - [Generate BIOS password](#generate-bios-password)
      - [Copying generated Disk Encryption Recovery Key into a Temporary Volume](#copying-generated-disk-encryption-recovery-key-into-a-temporary-volume)
      - [Sync data between your copies of Offline Backup Volume](#sync-data-between-your-copies-of-offline-backup-volume)
      - [Summary](#summary-5)
    + [Build Recovery Volume with new hardware profile](#build-recovery-volume-with-new-hardware-profile)
    + [BIOS Setup](#bios-setup)
      - [Enter BIOS](#enter-bios)
      - [Setting password](#setting-password)
      - [Entering Secure Boot Setup Mode](#entering-secure-boot-setup-mode)
      - [Clearing TPM](#clearing-tpm)
    + [Summary](#summary-6)
  * [Day-2 Operations](#day-2-operations)
    + [Machine Maintenance](#machine-maintenance)
      - [Booting up](#booting-up)
      - [OS Installation](#os-installation)
      - [Updating system configuration and rebuilding Recovery ISO image](#updating-system-configuration-and-rebuilding-recovery-iso-image)
      - [Updating Kernel](#updating-kernel)
      - [Updating BIOS](#updating-bios)
    + [YubiKey Maintenance](#yubikey-maintenance)
      - [Adding new OATH-TOTP secret](#adding-new-oath-totp-secret)
      - [Provisioning new YubiKey](#provisioning-new-yubikey)
      - [Unlocking locked Master PIN](#unlocking-locked-master-pin)
        * [Decommissioning old YubiKey device](#decommissioning-old-yubikey-device)
    + [Using Offline Backup Volume](#using-offline-backup-volume)
      - [Accessing](#accessing)
      - [Syncing data between Offline Backup Volumes](#syncing-data-between-offline-backup-volumes)
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
    + [How do you protect booting Recovery OS? Does it need to be protected?](#how-do-you-protect-booting-recovery-os-does-it-need-to-be-protected)
    + [Block-based backups vs File-based backups](#block-based-backups-vs-file-based-backups)
    + [Credentials which shouldn't be stored in Daily Password Manager](#credentials-which-shouldnt-be-stored-in-daily-password-manager)
      - [MFA Recovery Codes/Tokens](#mfa-recovery-codestokens)
      - [Password Salt](#password-salt)
      - [API Keys for services with MFA enabled](#api-keys-for-services-with-mfa-enabled)
      - [Private keys](#private-keys)
      - [Master Password and Master PIN](#master-password-and-master-pin)
      - [GPG AdminPIN and PIV PUK](#gpg-adminpin-and-piv-puk)
      - [Disk encryption recovery keys](#disk-encryption-recovery-keys)
      - [TPM Passwords](#tpm-passwords)
    + [Credentials which can be stored in Daily Password Manager](#credentials-which-can-be-stored-in-daily-password-manager)
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

#### Configuring Arch Linux ISO

##### Connecting to the Wi-Fi

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

##### Expanding available disk space

To make some space if you need to install more packages, run the following command:

```
mount -o remount,size=4G /run/archiso/cowspace
```

NOTE: All packages will be installed into RAM, so make sure you have enough of it available. Depending on the age of your ISO, you may also need to install updates to make things working.

NOTE: 4GB should be sufficient to install all updates, Gnome Shell and Firefox.

##### (Optional) Installing and running graphical interface

If you want to have a graphical interface during bootstrapping, run the following commands:

```sh
pacman -Syyu gnome-shell gnome-terminal firefox gnome-control-center
XDG_SESSION_TYPE=wayland dbus-run-session gnome-session
```

NOTE: This is only required to be done manually during bootstrapping process. Later on, your customized ISO may have it included out of the box.

#### Fetching required resources into temporary volume

With Arch Linux USB stick running, we can fetch this repository, verify it's signature and run a script, which will pull all required dependencies into a temporary volume, so you can continue following bootstrapping process without the internet access, to make sure generated secrets are not exposed to the internet.

##### Fetching repository

Run the following command to import GPG signing public key, which is used to sign releases in this repository.
This will allow to verify the signature of downloaded code.

```sh
curl https://github.com/invidian.gpg -o invidian.gpg
gpg --import invidian.gpg
```

Then, run the commands below to fetch and verify this repository:

```sh
export VERSION=testing2
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

Let's also save information where the repository has been downloaded, so we can later on copy it into Temporary Volume:

```sh
export REPOSITORY_PATH=$(pwd)
```

Finally, unpack the repository and make it your working directory, so we can use scripts from it in the next steps:

```sh
export TARGET_DIR=secure-and-reproducible-arch-linux
mkdir -p ./${TARGET_DIR} && tar zxvf ${VERSION}.tar.gz -C ${TARGET_DIR}
cd ${TARGET_DIR}/
```

Let's also

##### (Optional) Format temporary volume

Once running Arch, plug your USB devices which will serve as a temporary volume, then use the command below to identify plugged devices:

```sh
ls -d /dev/disk/by-id/* | grep -v -E -- '(-part[0-9]+|by-id/(dm|lvm|wwn|nvme-eui)-)'
```

If you are unsure, which of your device is which, in care of removable devices, you can run the following command:

```sh
journalctl -fk | grep 'SerialNumber:'
```

Then unplug and plug your device. It should print you the serial number, which you can find in the list created by the command above.

Once you identified your device, run the following command to make be able to automate remaining commands:

```sh
export TMP_DEVICE=<your full path to device>
export TMP_ID=tmp
```

Now, run the command below to examine the script which will create a new GPT partition table on your selected device and create one big partition on it:

```sh
cat ./scripts/partition-offline-backup-volume.sh
```

Once you confirm, that the script is safe to run, run it:

```sh
OBV_DEVICE=$TMP_DEVICE OBV_ID=$TMP_ID./scripts/partition-offline-backup-volume.sh
```

Now, create a `ext4` filesystem on the newly created partition using the following command:

```sh
export DEVICE=/dev/disk/by-partlabel/$TMP_ID
test -b $DEVICE && mkfs.ext4 -L $TMP_ID $DEVICE
```

##### Mount temporary volume

If your temporary volume was already formatted, so you did not identify it yet, do it as described above, then export information about it using commands below:

```sh
export TMP_DEVICE=<your full to device>
export TMP_ID=tmp
```

And run commands below to mount it:

```sh
export PARTITION=/dev/disk/by-partlabel/$TMP_ID
export MOUNTPOINT=/mnt/$TMP_ID
mkdir -p $MOUNTPOINT && mount $PARTITION $MOUNTPOINT
```

Finally, make temporary volume your working directory:

```sh
cd /mnt/$TMP_ID
```

The `/mnt/tmp` mountpoint will be used in the next steps.

##### Move repository into Temporary Volume

With Temporary Volume mounted, copy downloaded repository and associated GPG key into Temporary Volume by running the commands below:

```sh
cp -r $REPOSITORY_PATH/${TARGET_DIR}/ ./
```

##### Fetching dependencies

Use Terminal opened in previous step or make sure you're in the temporary volume as a working directly and run the following commands to download the packages, which we will install once we go into offline mode.

```sh
# Breakdown of dependencies:
# - hopenpgp-tools - Fecommended by https://github.com/drduh/YubiKey-Guide for linting your GPG key.
# - yubikey-manager - For configuring YubiKey.
# - sssd - For splitting your Master Password into multiple shards.
# - git - For versioning and syncing data on Offline Backup Volumes.
# - sbsigntools - For testing Secure Boot signing using YubiKey.
# - libp11 - PKCS#11 engine for sbsign, requires to work with YubiKey.
# - opensc - Smart card tools required for p11tool to detect the YubiKey as smartcard.
# - ccid - Smart card driver.
pacman -S hopenpgp-tools yubikey-manager sssd git sbsigntools libp11 opensc ccid
mkdir packages
cp /var/cache/pacman/pkg/* ./packages/
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

After the reboot, repeat the steps from [Mount temporary volume](#mount-temporary-volume) to make your Temporary Volume available and your working directory.

##### Installing dependencies offline

With temporary volume as your working directory, run the command below to install all required packages:

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
export OBV_ID=OBV1 # Paritition label is limited to 16 characters.
```

Now, run the command below to examine the script which will create a new GPT partition table on your selected device and create one big partition on it:

```sh
cat ./secure-and-reproducible-arch-linux-testing/scripts/partition-offline-backup-volume.sh
```

Once you confirm, that the script is safe to run, run it:

```sh
./secure-and-reproducible-arch-linux-testing/scripts/partition-offline-backup-volume.sh
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

###### Swapping slots

This guide use only one slot out of two available of OTP applet in YubiKey. First slot functionality is triggered by short touch and second slot is triggered by long touch.

By default first slot is configured with [Yubico OTP](https://demo.yubico.com/otp/verify), so one-time challenge will be typed into your computer when you touch the YubiKey button.

Even though OTP challenge is not confidential, accidental typing it might be annoying, so it is recommended to swap the slots, so first one will be used for HMAC-SHA1 Challenge-Response.

We swap slots instead of wiping or overriding first slot to retain a factory secret programmed by Yubico, so if you need to use Yubico OTP service with [production `cc` prefix](https://www.reddit.com/r/yubikey/comments/i5782b/overwriting_slot_1_reset/), it is still possible.

To swap the slots, run the following command:

```sh
ykman otp swap
```

This command is non destructive and you can run it as many times as you want. Slots will be swapped each time.

To see currently programmed slots, run:

```sh
ykman otp info
```

**NOTE: Make sure you run the swap command mentioned above for each of your YubiKey. **

###### Checking existing Challenge-Response configuration

If you want to find out if your device has already Challenge-Response configured on some slot, run the following command:

```sh
ykchalresp -1 'Sample #2'
```

Then, try running the command below:

```sh
ykchalresp -2 'Sample #2'
```

If any of the command succeeds and prints a hash, it means on the used slot Challenge-Response is already configured.

###### Generating Access Code

To avoid accidental removal of your OTP configuration, it is recommended to set up an access code, which will be required for each configuration change. We will generate random Access Code and store it on Offline Backup Volumes.

To generate Access Code and write it to the file, run the command below:

```sh
(LC_ALL=C tr -dc '[:digit:]' < /dev/urandom | head -c12; echo) > yubikey-slot-1-hmac-sha1-challenge-response-access-code
```

Now, because we have 2 slots on each device, we generate one more Access Code by running the command below:

```sh
(LC_ALL=C tr -dc '[:digit:]' < /dev/urandom | head -c12; echo) > yubikey-slot-2-hmac-sha1-challenge-response-access-code
```

###### Configuring access code

To configure Access Code on your device, run the commands below:

```sh
ykman otp settings --new-access-code $(cat yubikey-slot-1-hmac-sha1-challenge-response-access-code) 1
ykman otp settings --new-access-code $(cat yubikey-slot-2-hmac-sha1-challenge-response-access-code) 2
```

###### Verifying access code

To verify that your access code is functional, you can run the command below:

```sh
ykman otp swap
```

It should fail with the output similar to below:

```console
$ ykman otp swap
Swap the two slots of the YubiKey? [y/N]: y
Swapping slots...
Usage: ykman otp swap [OPTIONS]
Try 'ykman otp swap -h' for help.

Error: Failed to write to the YubiKey. Make sure the device does not have restricted access.
```

###### Generating Challenge-Response key

To be able to maintain redundancy between two keys, we must generate Challenge-Response key manually, then program it on each of YubiKeys.

To generate the key and write it to file, run the command below:

```sh
xxd -ps -l 20 /dev/urandom > yubikey-slot-1-hmac-sha1-challenge-response-secret
```

This command generates secret key from `/dev/urandom` in hex format with length of 40 characters, which will be suitable as Challenge-Response key.

###### Setting Challenge-Response key on the devices

With configuration generated, plug each of your YubiKey and run the following command to apply generated configuration:

```sh
ykman otp --access-code $(cat yubikey-slot-1-hmac-sha1-challenge-response-access-code) chalresp 1 -t $(cat yubikey-slot-1-hmac-sha1-challenge-response-secret)
```

###### Verifying Challenge-Response configuration

To verify, that both of your YubiKeys are configured the same way, you can run the command below for each of them. If everything is correct, they should both produce the same output:

```sh
ykchalresp -1 'Sample #2'
```

Additionally, if you like, you can reproduce the YubiKey functionality using the command below:

```sh
echo -n 'Sample #2'  | openssl dgst -sha1 -mac HMAC -macopt hexkey:$(cat yubikey-slot-1-hmac-sha1-challenge-response-secret) | awk '{print $2}'
```

###### hmac-lt64 configuration flag

By default, YubiKey Challenge-Response take challenges between 0 and 63 bytes and calculates response for them. With `ykpersonalize`, you can disable `hmac-lt64` configuration flag, which makes YubiKey always require 64 bytes challenge. Note, that this mode may not be compatible with some applications.

See [this GitHub issue](https://github.com/Yubico/yubikey-personalization/issues/174) for more details.

##### Setting up PIV applet

Next on the list is generation of the PIV applet, where we will store key pair with certificate, which will be used to sign the kernels for Secure Boot.

###### Generating Management Key

With YubiKey 5, you can either have only PIN configured, or PIN, PUK and Management Key. Since we want to have PUK functionality to make PIV block after unsuccessful PIN attempts, we need to generate the Management Key and PUK.

Run the command below to generate the Management Key:

```sh
export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -d '[:lower:]' | tr -cd '[:xdigit:]' | fold -w48 | head -1 > yubikey-piv-applet-management-key
```

###### Configuring Management Key

To use generated Management Key, run the command below for each YubiKey plugged:

```sh
ykman piv change-management-key --management-key 010203040506070801020304050607080102030405060708 --new-management-key $(cat yubikey-piv-applet-management-key)
```

**NOTE: `010203040506070801020304050607080102030405060708` Management Key used above is a default Management Key.**

###### Generating PUK

Now, we need to generate PUK, which will be used, when you type your PIN incorrectly 3 times. PUK will be stored on Offline Backup Volume, so once you lock your PIV applet, you will need access to it to be able to unlock it.

To generate PUK, run the command below:

```sh
export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -cd '[:digit:]' | fold -w6 | head -1 > yubikey-piv-applet-puk
```

Commands above are taken from https://developers.yubico.com/yubico-piv-tool/YubiKey_PIV_introduction.html

###### Setting PUK

To set PUK, run the command below with each of your YubiKeys plugged:

```sh
ykman piv change-puk --puk 12345678 --new-puk $(cat yubikey-piv-applet-puk)
```

###### Setting PIN

Finally, we can set up PIN, which will be used to unlock the PIV applet after plugging it in. For PIN, you should use [Master PIN](#master-pin) mentioned above.

Run the command below to configure PIN on each YubiKey:

```sh
ykman piv change-pin -P 123456
```

###### Summary

For now, we do not generate any secrets using PIV applet. This will be done at later stage when we generate Secure Boot keys.

##### Setting up OpenPGP applet

This guide use GPG keys to protect main part of disk encryption keys, as well for signing Git objects. This means we need to configure OpenPGP applet on YubiKeys to act as a GPG smartcard.

###### Setting Admin PIN

Similarly to PUK for PIV applet, OpenPGP applet has `Admin PIN`, which is used when you exceed your PIN attempts limit. To generate Admin PIN for your YubiKeys, run the command below:

**NOTE: This command will print your Admin PIN to the screen, so you can copy-paste it in the next step when configuring it. Make sure your display output is secure.**

```sh
export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -cd '[:digit:]' | fold -w8 | head -1 | tee yubikey-gpg-smartcard-admin-pin
```

If you use graphical interface, make sure you copy your Admin PIN to clipboard before proceeding. It will be required for the next step.

To configure Admin PIN, run the following command:

```sh
gpg --change-pin
```

Now, select option `3.` to change Admin PIN.

You will be prompted for the existing Admin PIN, which by default is `12345678`.

Repeat this step for each of your YubiKeys.

###### Setting PIN

Now, you can configure your regular PIN using [Master PIN](#master-pin). To do that, run the command below:

```sh
gpg --change-pin
```

And select option `1.` to change your PIN.

You will be prompted for the existing PIN, which by default is `123456`.

Repeat this step for each of your YubiKeys.

###### Enabling touch requirement

It is recommended to enable touch requirement for any of GPG operation, so in case when your machine gets compromised, attacker won't be able to use your GPG keys.

To enable it for all operations, run the following commands:

```sh
ykman openpgp set-touch --admin-pin $(cat yubikey-gpg-smartcard-admin-pin) aut on
ykman openpgp set-touch --admin-pin $(cat yubikey-gpg-smartcard-admin-pin) sig on
ykman openpgp set-touch --admin-pin $(cat yubikey-gpg-smartcard-admin-pin) enc on
```

Repeat this step for each of your YubiKeys.

###### Setting Reset Code

This guide do not make use of Reset Code. Reset Code in GPG applet is used only for resetting PIN capability. If you would like to generate and use Reset Code, generate it in similar way as Admin PIN was generated.

See [this link](https://forum.yubico.com/viewtopicd01c.html?p=9055#p9055) for more details.

##### Configuring and securing other YubiKey applets

YubiKey has also other applets available to use, like OATH-TOTP or FIDO which supports protecting with credentials. If you plan to use those applets and you prefer to have them secured, follow the steps similar to above to generate unique keys/passwords and store them on Offline Backup Volume.

This guide will later on use OATH-TOTP for TPM authenticity validation, but it does not require password protection.

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
export TEMPORARY_VOLUME=/mnt/tmp
cp $TEMPORARY_VOLUME/gpg.conf $GNUPGHOME/
```

Now you can run the command below to initialize the GPG database to verify the configuration:

```sh
gpg --list-keys
```

If successful, it should create few new files in `gnupg-workspace` directory.

##### Generate keys

###### Generating Master Key

First thing to do is to generate Master Key, which will be stored only on Offline Backup Volume. To do that, run the command below:

```sh
gpg --expert --full-generate-key
```

Now, select option:

```
ECC (set your own capabilities)
```

We use ECC as it is recommended algorithm nowadays.

Now, type `S`  to leave only `Certify` capability selected:

```sh
S
```

Then type `Q` to confirm the selection:

```sh
Q
```

Next, select `1` elliptic curve option. YubiKey supports `Curve 25519` and `secp256k1` and ``Curve 25519`` is more commonly used:

```sh
(1) Curve 25519
```

Choose that Master Key should never expire:

```sh
0
y
```

Next, type your real name which will be used as an human-readable identifier for your key.

```sh
John Doe
```

Then type your email address:

```sh
john.doe@example.com
```

**Now leave the `Comment` section empty, as this is [considered](http://web.archive.org/web/20200604060421/https://debian-administration.org/users/dkg/weblog/97) best practice.**

If everything you typed is correct, confirm with `o`:

```sh
o
```

Now, GPG will ask you to provide the passphrase for the key. Considering that by following this guide your GPG Master Key will be always kept offline and protected using your Master Password, it should be OK to leave the password blank.

After confirmation of empty password, your GPG key ID should be printed.

Copy the Key ID in `0x...` format and run the command below to make it available for other commands:

```sh
export KEYID=0xEAF8E1976169CB20
```

###### (Optional) Adding extra identities to your Master Key

If you have more than one username or email address, which you would like to associate with your new Master Key, you can add them using the command below:

```sh
gpg --edit-key $KEYID
```

Now, type `adduid`:

```sh
adduid
```

Type the details as explained above.

Finally, confirm with `o`:

```sh
o
```

You can repeat this process for as many identities as you have.

**Note: Added identities will be available to everyone, so make deliberate decision if you like to have those IDs being public information.**

Finally, type `save` to commit the changes:

```sh
save
```

###### Generating Signing key

Next key we need to generate is a Signing key, which will be used to sign information you generate like emails or git objects to proof they are coming from you. This key will be stored on YubiKey, but to be able to use the same key on both YubiKeys for redundancy, it must be generated offline, then transferred into both YubiKeys.

To generate the key, run the command below:

```sh
gpg --expert --edit-key $KEYID
```

Then, type `addkey`:

```sh
addkey
```

Select `(10) ECC (sign only)` kind of key:

```sh
10
```

And curve `(1) Curve 25519` as explained above:

```sh
1
```

Now, it is recommended to renew your keys yearly, to ensure you still have access to your Master Key, so select 1 year of expiration time:

```sh
1y
```

Verify the expiration date and confirm:

```sh
y
```

And confirm again:

```sh
y
```

Finally, commit the result by using:

```sh
save
```

Signing key can also be saved without password, as it will be transferred into YubiKey anyway.

###### Generating Encryption key

Next key to generate is Encryption key, which will be used to encrypt the data which only you will be able to decrypt. The procedure is almost identical to generating Signing key.

To generate the key, run the command below:

```sh
gpg --expert --edit-key $KEYID
```

Then, type `addkey`:

```sh
addkey
```

Select `(12) ECC (encrypt only)` kind of key:

```sh
12
```

And curve `(1) Curve 25519` as explained above:

```sh
1
```

Again, select `1y` expiration time as explained above:

```sh
1y
```

Verify the expiration date and confirm:

```sh
y
```

And confirm again:

```sh
y
```

Finally, commit the result by using:

```sh
save
```

Encryption key can also be saved without password, as it will be transferred into YubiKey anyway.

###### Generating Authentication Key

Last key we will generate is Authentication key. This key is used when you log in into remote servers to prove your identity. This can can be used for example for logging in using SSH. GPG also supports TLS authentication.

To generate the key, run the command below:

```sh
gpg --expert --edit-key $KEYID
```

Then, type `addkey`:

```sh
addkey
```

Now, depending on the services you are going to use your authentication key, you may select either `ECC` key (recommended) or older `RSA` key. Note, that some cloud providers like AWS do not support ECC key types at the time of writing. However, if you still prefer to use ECC key with GPG, you can generate additional RSA key using PIV applet, which you can use for "legacy" services.

If you select `(12) ECC (encrypt only)` kind of key, type:

```sh
11
```

Enable Authenticate capability:

```sh
A
```

Disable Sign capability:

```sh
S
```

Confirm selection:

```sh
Q
```

Then select curve `(1) Curve 25519` as explained above:

```sh
1
```

If you select `(8) RSA (set your own capabilities)`, type:

```sh
8
```

Enable Authenticate capability:

```sh
A
```

Disable Sign capability:

```sh
S
```

Disable Encrypt capability:

```sh
E
```

Confirm selection:

```sh
Q
```

Now choose `4096` as key length:

```sh
4096
```

Similarly to other keys, select `1y` expiration time:

```sh
1y
```

Verify the expiration date and confirm:

```sh
y
```

And confirm again:

```sh
y
```

Finally, commit the result by using:

```sh
save
```

Encryption key can also be saved without password, as it will be transferred into YubiKey anyway.

###### (Optional) Signing new Master Key with your existing key

If you already use GPG and you want to switch to use key which is stored on YubiKey, it is recommended to sign your new Master Key with your existing Master Key to proof to people trusting your existing key that this newly generated key belongs to you.

To do that, export your new public key using the command below:

```sh
gpg --export --armor $KEYID > $TEMPORARY_VOLUME/$KEYID.gpg
```

Now, unmount your temporary volume, plug it to machine where you have your existing master key available and use the command below to sign new key:

```sh
export NEW_KEY_ID=<KEYID from other machine>
gpg --sign-with EXISTING_KEY_ID --sign-key $NEW_KEY_ID
```

When it's done, you can export your new master key with new signature and copy it back onto temporary volume, so it can be imported on Offline Backup Volume.

```sh
gpg --export --armor $NEW_KEY_ID > TEMPORARY_VOLUME/$NEW_KEY_ID-signed.gpg
```

You can now also upload your new Master Key to key server, with included signature from old key. To do this, run the command below:

```sh
gpg --send-keys $NEW_KEY_ID
```

Mount back your temporary volume on Secure OS with Offline Backup Volume available and run:

```sh
gpg --import $TEMPORARY_VOLUME/${KEYID}-signed.gpg
```

#### Generating Secure Boot keys

This guide use Secure Boot to protect your machines against bootloader-level malware and to prevent unauthorized code execution on your machine. To use Secure Boot, you must generate your own set of keys for Secure Boot, which key used for signing the kernels will be stored on YubiKey. For that, you need PIV applet configured as explained in [Setting up PIV applet](#setting-up-piv-applet) section.

##### Checking if YubiKey PIV slot is in use

If you used your YubiKey before, it is good to check if there are any existing certificates on the key to avoid overriding it.

###### Checking if YubiKey PIV slot has certificate

To check if your YubiKey PIV slot has some certificate generated on a given slot, run the command below. In this case, we check slot `9c`:

```sh
ykman piv export-certificate 9c -
```

If there is a certificate already installed, certificate will be printed. Sample output:

```console
$ ykman piv export-certificate 9c -
-----BEGIN CERTIFICATE-----
MIICuDCCAaCgAwIBAgIUcLwNBpwgDIWAJSLpCKVny6O1kHwwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAwwLbWF0LXRlc3RpbmcwHhcNMjEwMzA3MTEzMTEwWhcNMjIw
MzA3MTEzMTEwWjAWMRQwEgYDVQQDDAttYXQtdGVzdGluZzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAJ/XJPOSP7gm3pm7NuRGRdtf4tLTUoywJZ3LJxXk
lQmuGRo91/SJ2wnxFLosfSkHuYK6tURgLuIfknXUezExT2IUC0ZRme/oPsvLQ1ij
IUbupzmbbbLFDjFUsRbyZ3xxSjxIH2GaTzh8K3YlKmr1F5kI6OdiDnCGhXHBlYr0
QeT091h3FG3P7A78mwv4+Rn8ifdL37uYXlWVuW78dWkiLMdFHyjRTrQMlj2TIoMd
Pi0+GfmTokziTgM2sDAkRhbkGQDghlFMjFahj//nQkYWWxVjE1KwvgFEwth4iIrl
IMOV0WNubSYP9dJm2bTjDO5WublxLe2MxMTnRaZVmSkrXi0CAwEAATANBgkqhkiG
9w0BAQsFAAOCAQEAjq3BgqrddMAo3f+W1t8/ZqdWmxdsNs5RUs8Mhgp9PgNxa0aP
zDIcuD7JIBrwmXNrobPZRmmPJbKmHP3230Gyq8DyeAoEHVxICKf7p3OTFA/adAWw
ZXmxP7tfW/P35cSsZvNjL50gVGc33eirRWibbVkDTn+3FhTLyQe3wmXTbrdZFTJN
2j58AiARQ2MX2av6hDDmwEPC1yGImRWkzzToOc8R3xt5oqy+RJ0b60UwRLWArfuJ
LpJ8ZEJ6ltTjZGgyMRHn7VamijkeAgoAHwkRTwKT9DshLwmC2oVIOhPVm7Wbdaox
6cIwjyZypyBw0Pawr0GlA0Sl4oo1v0kWL458xw==
-----END CERTIFICATE-----
```

If there is no certificate, you should get error similar to below:

```console
$ ykman piv export-certificate 9d -
Usage: ykman piv export-certificate [OPTIONS] SLOT CERTIFICATE
Try 'ykman piv export-certificate -h' for help.

Error: No certificate found.
```

###### Checking if YubiKey PIV slot has key pair

[Checking if slot has a certificate](#checking-if-yubikey-piv-slot-has-certificate) is recommended before checking if slot has a private key, as certificate generation attempt is used to determine if slot already has a key pair generated.

To check if slot has key pair generated, run the command below:

**NOTE: This command may wipe the certificate from your slot. Use with caution! It is recommended to check for certificate existence before running this command. **

```sh
cat <<EOF | ykman piv generate-certificate -s "testing" 9d -
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn9ck85I/uCbembs25EZF
21/i0tNSjLAlncsnFeSVCa4ZGj3X9InbCfEUuix9KQe5grq1RGAu4h+SddR7MTFP
YhQLRlGZ7+g+y8tDWKMhRu6nOZttssUOMVSxFvJnfHFKPEgfYZpPOHwrdiUqavUX
mQjo52IOcIaFccGVivRB5PT3WHcUbc/sDvybC/j5GfyJ90vfu5heVZW5bvx1aSIs
x0UfKNFOtAyWPZMigx0+LT4Z+ZOiTOJOAzawMCRGFuQZAOCGUUyMVqGP/+dCRhZb
FWMTUrC+AUTC2HiIiuUgw5XRY25tJg/10mbZtOMM7la5uXEt7YzExOdFplWZKSte
LQIDAQAB
-----END PUBLIC KEY-----
EOF
```

If slot already has some key, this command should return no output.

If slot is empty and there is no private key, you should see output similar to the following:

```console
$ ykman piv generate-certificate 9c testing.pem -s foo-testing
Enter PIN:
Enter a management key [blank to use default key]:
Usage: ykman piv generate-certificate [OPTIONS] SLOT PUBLIC-KEY
Try 'ykman piv generate-certificate -h' for help.

Error: Certificate generation failed.
Touch your YubiKey...
```

##### Generating Platform Key (PK) and Key Exchange Key (KEK)

Platform Key and Key Exchange Key for Secure Boot will be stored on Offline Backup Volume, as they are not required for daily operation. They will only be used during [Hardware Bootstrapping](#hardware-bootstrapping) process to roll out Database public key.

As some BIOSes may not support 4096 bit keys, we use 2048 bit keys.

As Secure Boot verification process to not take certificate expiry time into account, make it expire after one day.

Open Terminal and change working directory to one of Offline Backup Volumes.

First, adjust `IDENTIFIER` variable to your preference.

```sh
export IDENTIFIER="JohnDoe's"
```

Now, run the commands below to generate all necessary keys:

```sh

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
```

Those commands are taken from [Gentoo wiki](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki%27s_EFI_Install_Guide/Configuring_Secure_Boot_under_OpenRC#Saving_Current_Keystore_Values.2C_and_Creating_New_Keys).

##### Transferring Database Key into YubiKeys

With Secure Boot keys generate, now we can transfer Database key into the YubiKey.

First, we will import private key using the command below:

```sh
ykman piv import-key --management-key $(cat ../yubikey-piv-applet-management-key) --pin-policy ALWAYS --touch-policy ALWAYS 9c db.key
```

Once finished, we can import the certificate:

```sh
ykman piv import-certificate --management-key $(cat ../yubikey-piv-applet-management-key) --verify 9c db.crt
```

You can verify the import process by running:

```sh
ykman piv info
```

This process must be repeated for each of your YubiKeys.

##### Verifying signing capabilities

To verify, that both your YubiKeys can generate valid Secure Boot signature, we must configure PKCS#11 engine.

Run the commands below to configure it:

```sh
mkdir -p /etc/pkcs11/modules
echo "module: opensc-pkcs11.so" > /etc/pkcs11/modules/opensc-pkcs11.module
```

And make sure your `pcscd`daemon is running by executing the command below:

```sh
systemctl start pcscd.service
```

Now, run `p11tool` to verify it's able to detect your YubiKey:

```sh
p11tool --list-all-privkeys
```

You should get output similar to the following:

```console
$ p11tool --list-all-privkeys
warning: no token URL was provided for this operation; the available tokens are:

pkcs11:model=p11-kit-trust;manufacturer=PKCS%2311%20Kit;serial=1;token=System%20Trust
pkcs11:model=p11-kit-trust;manufacturer=PKCS%2311%20Kit;serial=1;token=Default%20Trust
pkcs11:model=PKCS%2315%20emulated;manufacturer=piv_II;serial=cf397c0faff98e2d;token=%20kernel-signing%20key
```

Now, we can generate test Secure Boot signature using the command below:

```sh
sbsign --engine pkcs11 --key 'pkcs11:manufacturer=piv_II' --cert db.crt --output test-secure-boot-signature --detached /run/archiso/bootmnt/arch/boot/x86_64/vmlinuz-linux
```

This command will ask you for PIN twice and you need to finalize the process by touching the YubiKey.

> NOTE: If you do not have `db.crt` file around anymore, you can generate it by running `ykman piv export-certificate 9c db.crt`, assuming you have already generated and transferred the certificate into your YubiKey.

Now, to verify generated signature, run:

```sh
sbverify --cert db.crt --detached test-secure-boot-signature /run/archiso/bootmnt/arch/boot/x86_64/vmlinuz-linux
```

If everything went well, you should get the following output:

```console
Signature verification OK
```

#### (Optional) Generating Password Salt

If you plan to use [Password Salt](#password-salt), it should be safe to save it on Offline Backup Volume in case you forget it.

#### Generating secrets for your first hardware

Part of [Hardware Bootstrapping](#hardware-bootstrapping) process is generation of [Disk Encryption Recovery Key](#disk-encryption-recovery-key) and BIOS password, which will be stored on Offline Secure Volume.

To save some time on rebooting and mounting volumes, we will generate them right now.

Encrypted version of Disk Encryption Recovery Key will also be stored in encrypted version in first [Recovery Volume](#recovery-volume), so we can perform regular automated Arch Linux installation.

Head to [Selecting hardware hostname](#selecting-hardware-hostname) step of [Generating hardware secrets](#generating-hardware-secrets) section and follow the steps from there to generate required hardware secrets, then return here.

### Saving and synchronizing data between Offline Backup Volumes

At this point, you should have all secrets created or generated, which are covered by the general bootstrap process. There will be more secrets to generate, which will be done for each machine you have, described in [Harware Bootstrapping](#hardware-bootstrapping) section, but this will be done later.

At this point, all secrets are stored on a single Offline Backup Volume and we need to sync them into the other volume. To do that, we will be using Git, which will allow us to handle extra checksums, versioning and synchronization of all secrets.

#### Configuring Git

First, we will generate basic Git configuration, which will use GPG. This can be done automatically using the command below:

```sh
export NAME=$(gpg --with-colons --list-keys $KEYID | grep ^uid | head -n1 | cut -d: -f 10 | cut -d\< -f1 | sed 's/ $//g')
export EMAIL=$(gpg --with-colons --list-keys $KEYID | grep ^uid | head -n1 | cut -d: -f 10 | cut -d\< -f2 | sed -E 's/( |>)$//g')
export SIGNING_KEY=$(gpg --with-colons --list-keys $KEYID | grep :s: | cut -d: -f5)
cat <<EOF > ~/.gitconfig
[user]
        email = ${EMAIL}
        name = ${NAME}
        signingkey = ${SIGNING_KEY}!
[commit]
        gpgsign = true
EOF
```

#### Initializing repository

Now, having mounted Offline Backup Volume as a working directory, we can initialize new Git repository and commit all generated files into it by running the commands below:

```sh
git init
git add --all
git commit -s -m "Initial commit"
```

You can now also verify, that Git signing is functional by running the command below:

```sh
git verify-commit HEAD
```

Do note, that signing commits here does not have much value, as we store Signing private key in this Git repository itself and it's not password protected. However, it proofs, that your Git configuration is functional.

#### Initial sync into other Offline Backup Volumes

Creating a copy of data into another Offline Backup Volume is as simple as running the command below:

```sh
export OBV_ID=OBV2
export MOUNTPOINT=/mnt/$OBV_ID
git clone . $MOUNTPOINT
```

#### Syncing further changes

If you rotate, modify or add new secrets in the future, to synchronize 2 Offline Backup Volumes, commit your changes in one copy, for example by running:

```sh
git add --all # To add all new, untracked files.
git commit -s
```

Then, change your working directory to the other Offline Backup Volume, for example by running:

```sh
export OBV_ID=OBV2
export MOUNTPOINT=/mnt/$OBV_ID
cd $MOUNTPOINT
```

And finally, run:

```
git pull
```

And if you want to pull from 2nd copy into the first one, make sure you configure the right origin URL by running the command as bellow:

```sh
git remote set-url origin /mnt/$OBV_ID
```

And also run:

```sh
git pull
```

### Transferring GPG keys into YubiKeys

With all generates secrets synchronized and versioned, you can now transfer generated GPG keys into all your YubiKeys. As `keytocard` GPG command removes the keys from your local GPG keyring, we will use `git restore` functionality to restore them to be able to transfer them into backup YubiKey.

To transfer keys into YubiKey, start by running the command below:

```sh
gpg --edit-key $KEYID
```

Now, select the Signature key:

```sh
key 1
```

It should change `ssb` in the line with key with `usage: S` to `ssb*`, marking the key as selected.

Now, initiate the transfer of the key by running:

```sh
keytocard
```

Select `(1) Signature key` slot for storing the key:

```sh
1
```

Next, deselect Signature key and select Encryption key:

```sh
key 1
key 2
```

And initiate transfer to the card:

```sh
keytocard
```

This time, select only available `(2) Encryption key` slot:

```sh
2
```

Next, deselect Encryption key and select authentication key:

```sh
key 2
key 3
```

Initiate transfer to card:

```sh
keytocard
```

Select `(3) Authentication key` slot:

```sh
3
```

Finally, confirm everything:

```sh
save
```

You can verify that your GPG keys has been transferred to YubiKey by running the command below:

```sh
gpg --card-status
```

Now, run the command below to restore your GPG keyring to original state:

```sh
git restore gnupg-workspace/
```

Unplug your current YubiKey and plug the backup one, then repeat the procedure described above, including `git restore` command.

### Copying public keys and certificates into Temporary Volume

As a last step in Offline Mode, before unplugging Offline Backup Volumes, we need to copy some of the generated secrets from it into a temporary volume, so we can embed them into a Recovery Volume we are going to build.

First, export your GPG public key, so we can upload it to key server:

```sh
gpg --export --armor $KEYID > /mnt/tmp/gpg-public-key.gpg
```

Next, copy Secure Boot certificates in various formats, to make sure we have format available, which is compatible with your BIOS, which will be needed for [Hardware Bootstrapping](#hardware-bootstrapping):

```sh
mkdir /mnt/tmp/secureboot
cp secureboot/compound_db.* secureboot/compound_KEK.* secureboot/db.{auth,cer,crt,esl} secureboot/KEK.{auth,cer,crt,esl} secureboot/PK.{auth,cer,crt,esl} /mnt/tmp/secureboot/
```

Now, you can unmount both Temporary Volume and Offline Backup Volumes by running the commands below:

```sh
sync && umount /mnt/*
```

Once finished, make sure you unplug your Offline Backup Volumes. Remember to never plug them into the machine connected to the network.

### Creating first Arch Linux bootable USB device

In this step, we will prepare your first Recovery Volume, which is Arch Linux bootable USB device. This process has more details described in [Recovery Volume maintenance](#recovery-volume-maintenance) section. Here, we are going to focus to create a basic Arch Linux ISO, which will allow you to perform automated Arch Linux installation over network.

Reboot your machine now and boot it again with Arch Linux ISO. Follow [Configuring Arch Linux ISO](#configuring-arch-linux-iso) and [Mount Temporary Volume](#mount-temporary-volume) again to prepare your environment.

#### Customizing your Arch Linux ISO profile

##### Network setup

##### SSH Access

##### GUI

#### Saving your Arch Linux ISO profile

#### Writing your Arch Linux ISO into Recovery Volume

### Summary



## Hardware Bootstrapping

### Generating hardware secrets

#### Booting Recovery Volume in Offline mode

To generate the secrets, boot your Recovery Volume and make sure it stays in Offline mode by stopping `systemd-networkd.service`  unit in first 30 seconds after boot. You should do it using the command below:

```sh
systemctl stop systemd-networkd.service
```

#### Mounting Offline Backup Volume

Next, make your Offline Backup Volume available. Use the following commands to identify the right device:

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

Finally, make your Offline Backup Volume your working directory using the command below:

```sh
cd $MOUNTPOINT
```

#### Selecting hardware hostname

Now, you need to decide how your machine will be named. This name will be used to identify device-unique secrets and as a `hostname` in your OS installation.

Run the command below to learn about allowed characters, length etc of the hostname:

```sh
man hostname.7
```

Once you decide on something, export information about it using this command:

```sh
export TARGET_HOSTNAME=dellxps15johndoe
```

#### Generate Disk Encryption Recovery Key

If your Secure Boot with TPM setup breaks for some reason, you will be able to use unique Disk Encryption Recovery Key for each of your device, which will be stored on Offline Backup Volume or encrypted in Recovery Volume, to access your data and possibly fix your installation.

It is recommended, that your Disk Encryption Recovery Key is at least 55 characters long, consisting of lower and upper case letters and numbers, which should give you at least 256 bits of entropy using [zxcvbn](https://dropbox.tech/security/zxcvbn-realistic-password-strength-estimation) algorithm. This should be sufficient to provide good protection (more described in [AES-256 Security](#aes-256-security) section) and be short enough it can be typed by hand.

To generate Disk Encryption Recovery Key, run the command below:

```sh
export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -cd '[:alnum:]' | fold -w55 | head -1 > ${TARGET_HOSTNAME}-disk-encryption-recovery-key
```

#### Generate BIOS password

This guide assumes each of your device has unique BIOS password configured. Due to difficulty of cracking the BIOS password and simplicity of simply resetting it, BIOS password can be short as it only provides the basic protection to your machine configuration.

However, it is still good to password to be unique per hardware and stored in your [Daily Password Manager](#daily-password-manager), so you don't have to remember it and you can access it easily.

Different BIOS-es have different password policies, so you may need to check if your BIOS is not limited to shorter maximum length than the default one used below. Usually 8 characters is acceptable, sometimes it's a limit, and sometimes it's a minimum length for "strong" password.

Command below will generate a BIOS password for your hardware and print it to the screen. If you have your Daily Password Manager available, you can save the password there.

If you only have one hardware available, write down printed BIOS password on a piece of paper, so you can use it in the next step, then destroy the piece of paper.

```sh
export BIOS_PASSWORD_LENGTH=8
export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -cd '[:alnum:]' | fold -w${BIOS_PASSWORD_LENGTH} | head -1 | tee ${TARGET_HOSTNAME}-bios-password
```

BIOS password security is described with more details in [BIOS Password](#bios-password) section.

#### Copying generated Disk Encryption Recovery Key into a Temporary Volume

If you want to make your Offline Backup Volume available again, run the following commands to identify the right device:

```sh
ls -d /dev/disk/by-id/* | grep -v -E -- '(-part[0-9]+|by-id/(dm|lvm|wwn|nvme-eui)-)'
journalctl -fk | grep 'SerialNumber:'
```

Now plug the device and export information about it:

```sh
export TMP_DEVICE=<your full to device>
export TMP_ID=tmp
```

And run commands below to mount it:

```sh
export PARTITION=${TMP_DEVICE}-part1
export MOUNTPOINT=/mnt/$TMP_ID
mkdir -p $MOUNTPOINT && mount $PARTITION $MOUNTPOINT
```

Then, create encrypted copy of generated Disk Encryption Recovery Key:

```sh
export RECIPIENT=$(gpg --with-colons --list-keys $KEYID | grep ^uid | head -n1 | cut -d: -f10)
gpg --encrypt --armor --recipient "$RECIPIENT" ${TARGET_HOSTNAME}-disk-encryption-recovery-key > /mnt/tmp/${TARGET_HOSTNAME}-disk-encryption-recovery-key.gpg
```

#### Sync data between your copies of Offline Backup Volume

Make sure you follow [Syncing data between Offline Backup Volumes](#syncing-data-between-offline-backup-volumes) to keep your Offline Backup Volumes synchronized, so you always have multiple actual copies of your secrets.

#### Summary

If you are following [Bootstrapping](#bootstrapping) process right now, head back to next section of it, which is [Saving and synchronizing data between Offline Backup Volumes](#saving-and-synchronizing-data-between-offline-backup-volumes).

### Build Recovery Volume with new hardware profile

TODO: add steps to add new hardware profile

### BIOS Setup

Next step of preparing your hardware for installing the OS is BIOS configuration.

#### Enter BIOS

Follow your device manual to enter the BIOS. Usually it's done by pressing one of `F12`, `DEL` or `F2` keys right after turning on the device.

#### Setting password

Once you entered the BIOS, first thing to do is to setup new password, which we generated in the previous step. Follow your device manual to do that.

#### Entering Secure Boot Setup Mode

Next thing we need to do right now is to find the Secure Boot settings in your BIOS and remove pre-installed keys from there, which will make machine enter "Setup Mode", which allows rolling in your own keys.

Follow your device manual to do that.

#### Clearing TPM

As part of initial hardware setup, you may also want to check the TPM settings on your device and clear it, to make sure there is no pre-installed objects there.

Again, follow your device manual to do that.

### Summary

With everything configured, jump to [OS Installation](#os-installation) section to install OS on your new hardware.

## Day-2 Operations

This section documents various processes, which are needed in daily use, like [Updating Kernel](#updating-kernel), [OS Installation](#os-installation) or handling [Lost YubiKey](#lost-yubikey).

### Machine Maintenance

#### Booting up

#### OS Installation

#### Updating system configuration and rebuilding Recovery ISO image

#### Updating Kernel

#### Updating BIOS


### YubiKey Maintenance

#### Adding new OATH-TOTP secret

#### Provisioning new YubiKey

#### Unlocking locked Master PIN

##### Decommissioning old YubiKey device

If you no longer want to use your YubiKey or you want to replace it with the new model, here is recommended list of steps, which will securely wipe all your secrets from your existing YubiKey.


### Using Offline Backup Volume

After initial bootstrapping, the following information is stored on your Offline Backup Volume:
- GPG Master Key
- Secure Boot Platform Key
- Secure Boot Key Encryption Key

#### Accessing

#### Syncing data between Offline Backup Volumes

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

### How do you protect booting Recovery OS? Does it need to be protected?

- Recovery OS uses Secure Boot, which guarantees it's **Authenticity (identity)**.
- Recovery OS uses `dm-verity` to generate hash of root filesystem, then is then added to the kernel command line parameters with EFISTUB and signed using Secure Boot Database Key. This guarantees it's **integrity**.
- What about possible credentials stored on the image? Private keys for WireGuard installation network? WiFi password? If you encrypt it, how do you decrypt?
  - There should be no plaintext secrets stored on the image except the WiFi password, which is required to enable installation over local wireless network. An attacker with physical access to your Recovery Image, may have physical access to your Ethernet network anyway, if you do not have 802.1X configured on Ethernet level or additional physical protection on the Ethernet ports.
    - Limiting/disabling DHCP does not offer any real security.
    - MAC address filtering does not offer good security either, as MAC addresses can be spoofed. It may also be difficult to roll out on some devices.
    - Security measures should be used on higher levels than MAC addresses (Layer 2) anyway to provide additional security for your network.
  - This guide stores GPG-encrypted Disk Encryption Recovery Keys on Recovery Volume to make them available during installation. For secrets which are not required for unattended boot (e.g. WiFi password), you can use this method to securely store them on Recovery Volume.
  - Storing other types of plaintext secrets in Recovery Image is not supported right now with this guide. If this is what you really need, perhaps you need to replace the `archiso` in Recovery Image build process to perform regular Arch Linux installation, including disk encryption, similar to what we will be finally using, then configuring `overlayfs` combined with `tmpfs` or similar configuration and mount your root partition in read-only mode, to get ISO like environment which cannot be permanently modified while used.

### Block-based backups vs File-based backups

This guide prefers file-based backups

### Credentials which shouldn't be stored in Daily Password Manager

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

- Corrupted Kernel update - If something goes wrong with kernel update process, then you need a Recovery Volume and recovery key to be able to fix your existing installation.
- Accidental BIOS update - If you update your BIOS without suspending the TPM requirement for disk encryption, then after the update your system will refuse to decrypt due to differences in PCR values in TPM.
- Accessing data on another device - If your device gets damaged and you wish to access your data using e.g. USB adapter, then the only way to decrypt the disk is using recovery key.
- Accessing data from insecure OS - If you wish to access your data from e.g. bootable USB device which is not Secure Boot signed for your machine, then you must use the recovery key.

NOTE: The recovery key should be at least 55 uppercase, lowercase and number characters long to provide enough entropy against brute-force attacks, which might be a trouble for type by hand sometimes, though from my experience it's doable. If not, see [Old Android phone as Offline Password Manager](#old-android-phone-as-offline-password-manager).

#

#### TPM Passwords

Depending on TPM version on your hardware, you will either need to manage one or more passwords to configure TPM on each of your devices.

For TPM1.2, there is only single owner password which is required for all TPM operations.

With TPM 2.0, each hierarchy (group of objects) can be managed using separate password. This guide only stores few secrets in TPM.

### Credentials which can be stored in Daily Password Manager

Depending on your preference, here are the credentials, which you probably can store in your [Daily Password Manager](#daily-password-manager) and it shouldn't in a significant way
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