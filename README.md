# Secure and reproducible Arch Linux

This guide has the following goals:
- Automate secure installation of Arch Linux.
- Document security best practices and processes around performing backups, using YubiKeys, operating Secure Boot etc. in a single place.

This guide is mainly targets developers and systemd administrators using Linux as daily operating system on their workstations, which either use or would like to use Arch Linux.

## Table of Contents
 1. [Requirements](#requirements)
 2. [Bootstrapping](#bootstrapping)
 3. [Day-2 Operations](#day-2-operations)
 3. [Miscellaneous](#miscellaneous)

## Requirements

This section describes what hardware/software is required to be able to make full use of this guide.

Following hardware is required:

<dl>
  <dt>

	1 x (or more) x86 Computer with UEFI, Secure Boot and TPM support

	</dt>
  <dd>

	This guides assumes you have personal machine which will be used for daily operation.
	The guide also supports customized installation for each machine if you have more than one.
	The machine can be as well a virtual machine, though this is not recommended from security point of view, as host machine may not be trusted.

	</dd>


  <dt>

	1 x Temporary Computer running Linux, Windows or macOS

	</dt>
  <dd>

	For bootstrapping process, this guide requires you to have a machine running modern OS, from which you will be able to create a bootable USB stick with [Secure OS](#secure-os).

	</dd>


  <dt>

	2 x Hardware security device with PIV, OpenPGP and OATH - HOTP like [YubiKey 5 Series](https://www.yubico.com/products/compare-yubikey-5-series/)

	</dt>
  <dd>

	The main point of this guide is to make use of hardware security device as much as possible. Two devices are required so one can be kept in secure place as a backup in case primary one is lost, stolen or damaged.

	</dd>


  <dt>

	2 x Dedicated removable storage device (e.g. pendrive) for offline backup of master keys and passwords

	</dt>
  <dd>

	Some secrets generated as part of this guide (e.g. GPG master key) should be kept on always-offline volume to maximize their security.
	To ensure redundancy for those volumes, it is recommended to have at least 2 copies of them, to be able to handle situation when one of them gets corrupted or simply breaks.
	Those volumes may simply be encrypted pendrives.

	</dd>


  <dt>

	1 x (or more) dedicated removable storage device (e.g. pendrive) for a OS recovery volume

	</dt>
  <dd>

	This guide assumes data stored on daily computer is either version controlled, reproducible or regularly backed up into a local storage.
	This means it should be possible and it is recommended to be able to re-install the OS on machine at any time in a timely manner.
	To be able to do that, one should always keep a dedicated OS recovery volume, which is capable of performing fully automated OS installation.
	Having this possibiltiy allows not treating your workstation as [snowflake](#snowflake), giving you confidence, that when workstation breaks or gets stolen, you can quickly recover from it.

	</dd>


  <dt>

	2 x Temporary removable storage device (e.g. pendrive) for booting Secure OS and temporary storage

	</dt>
  <dd>

	As part of bootstrapping process and in case of some incidents, it is recommended to have two storage devices from which one can be formatted to allow installing Secure OS (e.g. Tails) on it and other to be able to store files when rebooting machine from OS connected to the internet to offline mode.

	</dd>


  <dt>

	1 x Dedicated removable storage device (e.g. USB HDD, network disk) for local backups

	</dt>
  <dd>

	Following [3-2-1 Backup Rule](#3-2-1-backup-rule) and to be able to quickly restore your last backup (restoring from local disk will be faster than restoring from internet), it is recommended to have a local storage available, which do not require internet access.

	</dd>


  <dt>

  1 x Dedicated S3-compatible remote storage server (e.g. Minio instance, AWS S3) for remote backups

  </dt>
  <dd>

  Again, following [3-2-1 Backup Rule](#3-2-1-backup-rule), to keep your backups geographically secure, it is recommended to have a remote storage server for keeping another copy of your backups, in case when both active copy and local backup gets damaged (e.g. in apartment fire).

  </dd>
</dl>


## Bootstrapping

This section explains steps, which needs to be performed once to start using practices defined in this guide.
It includes tasks like generating [GPG Master Key](#gpg-master-key), creating [Master Password](#master-password), generating [Secure Boot Platform Key (PK)](#secure-boot-platform-key-pk) etc.

## Day-2 Operations

This section documents various processes, which are needed in daily use, like [Updating Kernel](#updating-kernel), [OS Installation](#os-installation) or handling [Lost YubiKey](#lost-yubikey).

### OS Installation

### Updating Kernel

### Lost YubiKey

## Miscellaneous

This section contains useful information and notes not mentioned in the sections above.

### Credentials which shouldn't be stored in [Daily Password Manager](#daily_password_manager)

This section contains list of credentials which are recommended to not be stored in [Daily Password Manager](#daily_password_manager),
as storing them there may have security implications.

<dl>
  <dt>2FA Recovery Codes</dt>
  <dd>It is not recommended to keep 2FA Recovery Codes in your Daily Password Manager, because if content of your Daily Password Manager leaks, it allows an attacker to bypass the requirement of your YubiKey to log in into 2FA enabled services.</dd>
  <dt>Password Salt</dt>
  <dd>If you add "salt" to passwords stored in Daily Password Manager for extra security, make sure the salt is not stored there too. This also applies when you re-use salt for some other purposes e.g. as a PIN for GPG/PIV.</dd>
</dl>

### Glossary

<dl>
  <dt name="daily_password_manager">Daily Password Manager</dt>
  <dd>Password manager, which you use for every day logging in on your end devices like laptop or smartphone. This guide use KeePassXC, as it supports YubiKeys as a factor for unlocking the password database.</dd>
  <dt>Offline Password Manager</dt>
  <dd>Password manager, stored on encrypted volume, which you only access from Live USB, which has no internet connection. It holds all critial credentials, which are not required during daily operation like AdminPIN, PUK, YubiKey PIV ManagementKey, Secure Boot Platform Key etc.</dd>
  <dt name="3-2-1-backup-rule">3-2-1 Backup Rule</dt>
  <dd>Backup rule saying you should always have at least <b>3</b> copies of your data, store <b>2</b> backup copies on different devices or storage media and keep at least <b>1</b> backup copy offsite.</dd>
  <dt name="snowflake">Snowflake</dt>
  <dd>Snowflake is servers/machines, which configuration has drifted from original or automated configuration. Such drift is not desired, as configuration of such machines are hard to reproduce, which makes the recovery process harded when machine breaks.</dd>
  <dt name="secure-os">Secure OS</dt>
  <dd>Operating System focused on security and privacy, for example <a href="https://tails.boum.org/">Tails</a>.</dd>
  <dt name="gpg-master-key">GPG Master Key</dt>
  <dd>GPG Master Key is a main source of trust for your GPG identity. This key has only signing capabilities, it is used only to sign and revoke your <a href="#gpg-sub-keys">GPG sub-keys</a> and it should only be stored on offline volumes to minimize the risk of leaking</dd>
  <dt name="master-password">Master Password</dt>
  <dd>Master password is the only password you must remember when following this guide. This password is used for unlocking your daily password manager and to decrypt <a href="#offline-backup-volume">Offline Backup Volumes</a>. This password should be long and complex to make sure it cannot be brute-forced.</dd>
  <dt name="offline-backup-volume">Offline Backup Volume</dt>
  <dd>Offline Backup Volume is a local storage device (e.g. Pendrive), encrypted using <a href="#master-password">Master Password</a>, which contains all secrets like <a href="#gpg-master-key">GPG Master Key</a>, which must be kept secure at all cost. Accessing it's data should only be performed from <a href="#secure-os">Secure OS</a> with no network access.</dd>
  <dt name="#secure-boot-platform-key-pk">Secure Boot Platform Key (PK)</dt>
  <dd>Top level X.509 certificate with RSA key-pair used in Secure Boot process. "Platform" in "Platform Key" refers to <a href="https://en.wikipedia.org/wiki/Computing_platform">Computing platform</a>, which can be
an actual piece of hardware you execute code on, but can also be a virtualized environment or a web browser.<br><br>Owning Platform Private Key allows you to proof to the UEFI that you are the physical owner of the hardware.<br><br>This trust is established by requiring physical presence to the unit (platform) to "take ownership", so to add initial PK.<br><br>If the attacker poseses the Platform Private Key and access to the hardware, it does not give them direct access to execute code on the platform, as one needs to execute code, which will add a malicious public key to the signature database.<br><br>Usually this key is populated with device manufacturer (OEM) key and it signs KEK keys, including Microsoft CA.<br><br>This guide assumes that you are platform owner, so as part of <a href="#bootstrapping">Bootstrapping</a> process you will generate and roll your own Platform Key, which will later be stored on <a href="#offline-backup-volume">Offline Backup Volumes</a>, as it is not required for daily operation.</dd>
</dl>
