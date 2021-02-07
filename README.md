# Secure and reproducible Arch Linux

This guide has the following goals:
- Automate secure installation of Arch Linux.
- Document security best practices and processes around performing backups, using YubiKeys, operating Secure Boot etc. in a single place.
- Provide optimal security against unauthorized access to online services you use.
- Provide optimal security against unauthorized access to data on your devices.

This guide is mainly targets developers and systemd administrators using Linux as daily operating system on their workstations, which either use or would like to use Arch Linux.

## Table of Contents
 1. [Requirements](#requirements)
 2. [Bootstrapping](#bootstrapping)
 3. [Day-2 Operations](#day-2-operations)
 4. [Miscellaneous](#miscellaneous)

## Assumptions

This section describes possible attack scenarios against the data which this guide tries to protect.

### Security of your Daily Password Manager

While assessing the security of your Daily Password Manager, we must consider 2 distinct circumstances. The first one is how you usually access your password manager. The second one is how attacker can get access to it.

In the regular circumstances, your Daily Password Manager will be protected by the following factors:

[Copy of your Daily Password Manager database file](#copy-of-your-daily-password-manager-database-file)

This data will be stored on the following devices:

- Any of your daily devices like laptop or mobile phone
- Your local backup device
- Your remote backup storage

#

[Your Master Password](#your-master-password)

This password should never be written down or stored directly to make it harder to leak. Harder does not mean impossible, as for example, if you type your password on a compromised device (e.g. with software keylogger) or via hardware keylogger, your password will effectively be compromised. This is why it is important to only type your Master Password on trusted devices.

#

[Challenge Secret from your Hardware Security Module](#challenge-secret-from-your-hardware-security-module)

Last factor required to get access to your password manager is a physical possession and physical presence of your Hardware Security Device, in this case YubiKey.

E.g. if someone takes over your machine using remote control software, they won't be able to open your locked password manager.

#

An attacker may have additional ways of getting information from your password manager. This includes scenarios like:

- Compromising your machine on software level (e.g. rogue software update), then accessing your password manager data on software level
- Getting physical access to your unlocked machine with unlocked password manager.

### Security of your online services

The same 2 distinct circumstances applies to security of your online services. The first one is how you usually access your password manager. The second one is how attacker can get access to it.

The security of online services you use will differ from service to service. All services are usually protected with the following measures:

[High-entropy unique password](#high-entropy-unique-password)

Using password manager allows you to use unique password for every service, with optimal level of entropy to make used password impossible to brute-force.

#

Some services over MFA authentication using the following mechanism:

[OATH TOTP (Time-based One-Time Password)](#oath-totp-time-based-one-time-password)

Most popular 2nd authentication factor (2FA). In this guide, TOTP secrets are stored on YubiKey and obtaining them requires physical touch of the device. This means if someone compromises your machine remotely, they won't be able to obtain codes required for logging in into the services.

#

Some services may also offer FIDO2 authentication. In such case, the protection is based on 2 factors:

[Physical possession and presence of Hardware Security Module](#physical-possession-and-hardware-presence-of-hardware-security-module)

YubiKey offers FIDO2 authentication, where secret key is stored on your YubiKey and touch is required to confirm physical presence.

#

[FIDO2 PIN (usually Master PIN)](#fido2-pin-usually-master-pin)

As a second factor, PIN is used so even if someone steals your security key, they won't be able to use it to impersonate you.

#

When attacker wants to take over your online account, they have the following attack vectors:

[Compromising your Daily Password Manager via software](#compromising-your-daily-password-manager-via-software)

If an attacker gets remote access to your Daily Password Manager, they can then access all the services, which are not protected by MFA. Services protected with OATH-TOTP or FIDO2 should remain safe.

[Compromising online service itself](#compromising-online-service-itself)

If targeted online service itself is vulnerable to some attacks, exploiting such vulnerability may allow an attacker to take over your account in there.

[Man-in-the-middle (MITM)](#man-in-the-middle)

If network environment you work in is controlled by attacker, they may trick you into visiting their own version of service to trick you to send them your password. In such scenario, again, accounts using MFA should remain secure.

[Phishing](#phishing)

An attacker may try to trick you into telling them you own password. This scenario is also safe for accounts using MFA.

### Security of your data

## Requirements

This section describes what hardware/software is required to be able to make full use of this guide.

Following hardware is required:

#### [1 x (or more) x86 Computer with UEFI, Secure Boot and TPM support](javascript:void(0);)

This guides assumes you have personal machine which will be used for daily operation.
The guide also supports customized installation for each machine if you have more than one.
The machine can be as well a virtual machine, though this is not recommended from security point of view, as host machine may not be trusted.

#

#### [1 x Temporary Computer running Linux, Windows or macOS](javascript:void(0);)

For bootstrapping process, this guide requires you to have a machine running modern OS, from which you will be able to create a bootable USB stick with [Secure OS](#secure-os).

#

#### [2 x Hardware security device with PIV, OpenPGP and OATH - HOTP like ](javascript:void(0);)[YubiKey 5 Series](https://www.yubico.com/products/compare-yubikey-5-series/)

The main point of this guide is to make use of hardware security device as much as possible. Two devices are required so one can be kept in secure place as a backup in case primary one is lost, stolen or damaged.

#

#### [2 x Dedicated removable storage device (e.g. pendrive) for offline backup of master keys and passwords](javascript:void(0);)

Some secrets generated as part of this guide (e.g. GPG master key) should be kept on always-offline volume to maximize their security.
To ensure redundancy for those volumes, it is recommended to have at least 2 copies of them, to be able to handle situation when one of them gets corrupted or simply breaks.
Those volumes may simply be encrypted pendrives.

#

#### [1 x (or more) dedicated removable storage device (e.g. pendrive) for a OS recovery volume](javascript:void(0);)

This guide assumes data stored on daily computer is either version controlled, reproducible or regularly backed up into a local storage.
This means it should be possible and it is recommended to be able to re-install the OS on machine at any time in a timely manner.
To be able to do that, one should always keep a dedicated OS recovery volume, which is capable of performing fully automated OS installation.
Having this possibiltiy allows not treating your workstation as [snowflake](#snowflake), giving you confidence, that when workstation breaks or gets stolen, you can quickly recover from it.

#

#### [2 x Temporary removable storage device (e.g. pendrive) for booting Secure OS and temporary storage](javascript:void(0);)

As part of bootstrapping process and in case of some incidents, it is recommended to have two storage devices from which one can be formatted to allow installing Secure OS (e.g. Tails) on it and other to be able to store files when rebooting machine from OS connected to the internet to offline mode.

#

#### [1 x Dedicated removable storage device (e.g. USB HDD, network disk) for local backups](javascript:void(0);)

Following [3-2-1 Backup Rule](#3-2-1-backup-rule) and to be able to quickly restore your last backup (restoring from local disk will be faster than restoring from internet), it is recommended to have a local storage available, which do not require internet access.

#

#### [1 x Dedicated S3-compatible remote storage server (e.g. Minio instance, AWS S3) for remote backups](javascript:void(0);)

Again, following [3-2-1 Backup Rule](#3-2-1-backup-rule), to keep your backups geographically secure, it is recommended to have a remote storage server for keeping another copy of your backups, in case when both active copy and local backup gets damaged (e.g. in apartment fire).

#

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

#### Getting Tails

First step of bootstrapping is to get a Tails USB Stick created. We will use Tails without network configured for secrets generation.

For this step, following items are required from [Requirements](#requirements) section:
- 1 x Temporary removable storage device (e.g. pendrive)
- 1 x Temporary computer running Windows, Linux or macOS

With items above prepared, head to [Download and install Tails](https://tails.boum.org/install/index.en.html) and prepare your USB stick.

Before rebooting into Tails, make sure you remember an address of this guide, so you can continue following it there.

Once rebooting into Tails, make sure you configure your network.

#### Fetching required resources into temporary volume

With Tails running, we can fetch this repository, verify it's signature and run a script, which will pull all required dependencies into a temporary volume, so you can continue following bootstrapping process without internet access, to make sure generated secrets are not exposed to the internet.

##### (Optional) Formatting temporary volume

If your pendrive is not formatted yet, use `Utilities -> Disks` application on Tails to select the right disk to format
and create a filesystem on it.

This step must be done only once and automating it in a secure way is complex, so doing it via UI is acceptable.

##### Mount temporary volume

With temporary volume formatted, use `Accessories -> Files` to mount it. Once mounted, right-click in the window and open
the terminal in mounted location.

##### Fetching repository

Run the following command to import GPG signing public key, which was used to sign releases in this repository.
This will allow to verify the signature of downloaded code.
```sh
wget -O- https://github.com/invidian.gpg | gpg --import
```

Then, run the commands below to fetch and verify this repository:

```sh
VERSION=testing
wget https://github.com/invidian/secure-and-reproducible-arch-linux/releases/download/${VERSION}/${VERSION}.tar.gz.asc
wget https://github.com/invidian/secure-and-reproducible-arch-linux/archive/${VERSION}.tar.gz
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
sudo apt -y install --download-only wget gnupg2 gnupg-agent dirmngr cryptsetup scdaemon pcscd secure-delete hopenpgp-tools yubikey-personalization yubikey-manager
cp /var/cache/apt/archives/*.deb ./
```
Next, visit [Arch Linux Download page](https://archlinux.org/download/), find appropriate mirror for you and download latest Arch Linux ISO from it. We will use this ISO to build a personalized Arch Linux ISO, which will be much easier to do from Arch Linux itself.

For example, run the following commands to download the ISO and the ISO signature from Worldwide mirror:
```sh
export VERSION=2021.01.01
wget http://mirror.rackspace.com/archlinux/iso/${VERSION}/archlinux-${VERSION}-x86_64.iso
wget http://mirror.rackspace.com/archlinux/iso/${VERSION}/archlinux-${VERSION}-x86_64.iso.sig
```

Next, we will download GPG Public Key which was used to create a signature, so we can verify it. You can do it with the following command:
```sh
gpg --keyserver keyserver.ubuntu.com --recv-keys 0x4aa4767bbc9c4b1d18ae28b77f2d434b9741e8ac
```

Finally, verify the image with the command below:
```sh
gpg --verify archlinux-${VERSION}-x86_64.iso.sig archlinux-${VERSION}-x86_64.iso
```

You should find output similar to the one above, including the warning.

Next, download hardended GPG configuration we will use when generating GPG keys:
```sh
wget https://raw.githubusercontent.com/drduh/config/master/gpg.conf
```

#### Rebooting into offline mode

With all dependencies from the internet pulled, we can now reboot to make sure our OS has not been tampered and to make sure we stay in offline mode.

When starting Tails, make sure you configure administator password and you disable network access.

After the reboot, mount the temporary volume, unpack this repository and continue following the instruction.

### Creating secrets

Now we can proceed with the secrets generation.

#### Master Password

First thing to do is to create and memorize your personal [Master Password]. It will be used to protect your [Daily Password Manager](#daily-password-manager) and to decrypt [Offline Backup Volumes](#offline-backup-volume).


#### Backup volumes

With your new Master Password in mind, plug your USB devices which will serve as a [Offline Backup Volumes](#offline-backup-volume) and use `Utilities -> Disks` application on Tails to create a partition and **encrypted** filesystem on them.

If you are short on USB slots, plug and format them one by one.

At the end, leave at least one device plugged, decrypt it and mount it, so we can save some files there.

#### Generating GPG Master Key

Open Terminal and change working directory to one of Offline Backup Volumes. Then run the following commands:
```sh
export GNUPGHOME=$(pwd)/gnupg-workspace
mkdir -p "$GNUPGHOME"
chmod 0700 "$GNUPGHOME"
```

Now, copy previosly downloaded `gpg.conf` file from temporary volume into working directory and run:
```sh
mv gpg.conf "$GNUPGHOME/"
```

##### Creating Arch Linux bootable USB device

With downloaded and verified Arch Linux ISO, you can now plug your USB device which you would like to use as an [OS Recovery Volume](#os-recovery-volume). For now we will write vanilla Arch Linux ISO on it to be able to create a customized version of it.

For simplicity, you can again use `Utilities -> Disks` application on Tails, select the right device, then open menu and select "Restore Disk Image" option there.

After successful disk restoration, you can unplug this USB device for now, we will need it at latest stage.

## Day-2 Operations

This section documents various processes, which are needed in daily use, like [Updating Kernel](#updating-kernel), [OS Installation](#os-installation) or handling [Lost YubiKey](#lost-yubikey).

### Machine Maintenance

#### Booting up

#### OS Installation

#### Updating system configuration and rebuilding Recovery ISO image

#### Updating Kernel

#### Bootstrapping new hardware


### YubiKey Maintenance

#### Lost YubiKey

In case when your YubiKey gets lost or stolen.

#### Damaged YubiKey


### Using Offline Backup Volume

After initial bootstrapping, the following information is stored on your Offline Backup Volume:
- GPG Master Key
- Secure Boot Platform Key
- Secure Boot Key Encryption Key

#### Accessing

#### Signing someone else's GPG key

#### Storing MFA recovery tokens

#### Extending expiry time of your GPG keys

#### Updating

In the following situations, you need to update the content of your Offline Backup Volume:
- Rotation of Master Password

  - Master Password
  - PIN
  - GPG AdminPIN
  - PIV PUK
  - YubiKey Challenge-Response secret
  - Secure Boot Platform Key (PK)
  - Secure Boot Key Encryption Key (KEK)
  - (Optional) Password salt

### Incident responses

#### Rotating Master Password

It is recommended to change your Master Password if the information protected by Master Password is compromised.

In this guide, following data volumes are protected by Master Password:
- Daily Password Manager
- Offline Backup Volume

Compromising any of this data volumes allows attacker to perform an offline attack on them, to eventually get access
to the information inside.

The time window to successfully attack such encrypted volume is a time where information inside is still considered safe.
However, you may not know that the encrypted volume has leaked or you don't know what information an attacker alread have.
For instance, an attacker may already have some idea what form your Master Password is, which reduces the attack window.

If those volumes were not encrypted, attacker would have access to information inside immidiately (in 0 time).

During this time window, it is recommended to rotate all your secrets stored on the volumes listed above, so when an attacker
finally cracks them, they will no longer be useful.

In this case, both data volumes are encrypted using AES-256. Assuming that the password has high enough entropy (AES-256 use 256 bits keys,
so password should have at least 256 bits of entropy), the data should be considered safe from brute-force attacks, even if you consider growing
computing power efficiency (doubles over ~3-5 years, so complexity decreases from 2^256 to 2^255 over ~3-5 years), raise of quantum computing (initial
algoritms can reduce required computation complexity by half, so from 2^256 to 2^128) etc.

#### Compromised Daily Password Manager file

#### Compromised Offline Backup Volume

In case of burglary into the location where Offline Backup Volumes are stored,

#### Destroyed Offline Backup Volume

#### Revoking your GPG sub-keys

#### Restoring your Master Password from shards

## Miscellaneous

This section contains useful information and notes not mentioned in the sections above.

### Block-based backups vs File-based backups

This guide prefers file-based backups

### Credentials which shouldn't be stored in [Daily Password Manager](#daily-password-manager)

This section contains list of credentials which are recommended to not be stored in [Daily Password Manager](#daily-password-manager),
as storing them there may have security implications if password manager gets compromised.

#### [MFA Recovery Codes/Tokens](javascript:void(0);)

It is not recommended to keep MFA Recovery Codes in your Daily Password Manager, because if content of your Daily Password Manager leaks, it allows an attacker to bypass the requirement of your YubiKey to log in into 2FA enabled services. See [Storing MFA recovery tokens](#storing-mfa-recovery-tokens) section to learn how to safely store MFA Recovery Tokens.

#

#### [Password Salt](javascript:void(0);)

If you add "salt" to passwords stored in Daily Password Manager for extra security, make sure the salt is not stored there too. This also applies when you re-use salt for some other purposes e.g. as a PIN for GPG/PIV.</dd>

#

#### [API Keys for services with MFA enabled](javascript:void(0);)

If you protect access to certain service using MFA, but you store API keys with full privileges in your Daily Password Manager, this effectively breaks the purpose of using MFA, as obtaining the API key will effectively
give an attacker full access to the service.

#

#### [Private keys](javascript:void(0);)

Whenever possible, Hardware Security Module should be used to store your private keys instead of Daily Password Manager.

#

#### [Master Password and Master PIN](javascript:void(0);)

Considering, that this information should never be digitally saved, it is best practice to not put those in your Password Manager either.

This allows to treat those authorization factors as "something you know".

#### [GPG AdminPIN and PIV PUK](javascript:void(0);)

If one has access to your GPG AdminPIN or PIV PUK, they can try to brute-force your PIN and they may modify settings on your smartcard in case GPG AdminPIN.

Also, if your Password Manager gets compromised (e.g. you leave unlocked machine with unlocked password manager), having a PUK or AdminPIN allows an evil actor
to change the PIN on your security token, which effectively gives them access to your security token.

However, if you lock your YubiKey, the only way to unlock it is when you get access to your Offline Backup Volume, which might not be very convinient.

#### [BIOS Password](javascript:void(0);)

The BIOS password protects your machine from executing malicious code and can be used by attacker to for example disable Secure Boot on your machine, which
can trick you into getting your master password.

### Credentials which can be stored in [Daily Password Manager](#daily-password-manager)

Depending on your preference, here are the credentials, which you probably can store in your Daily Password Manager and it shouldn't in a sagnificant way
degrade your level of security.

### What this guide does not protect from

#### Operating on compromised machine

Considering the following facts:
- Most likely Linux desktop machines are not a common target for malware.
- Minimizing the damage from operating on a compromised machine is very inconvinient.
- On a desktop machine, user data is most likely more valuable than system data.

This guide only slightly reduces the damage in situation, where your machine gets compromised.

Assuming that your machine gets compromised (e.g. via RCE vulnerability + privilege escalation),
the following things happen:
- All unencrypted data stored on this machine should be considered public.
- All online services which do not use MFA should be considered compromised.
- All online services which active sessions you have opened on your machine (browser, API keys etc),
  should be considered compromised.
- Your Master Password and Master PIN are most likely compromised.
- Other systems where your machine has unattended access (e.g. Kubernetes clusters)

Following information remains safe:
- Your GPG identity, as it is protected by physical touch.
- All online services which you do not have active sessions opened.

#### Apartment theft

If one breaks in into your apartment, ties you up and beats you up until you reveal your credentials to them,
this guide most likely won't help you.

### Glossary

#### [Daily Password Manager](#daily-password-manager)

Password manager, which you use for every day logging in on your end devices like laptop or smartphone. This guide use KeePassXC, as it supports YubiKeys as a factor for unlocking the password database.

#

#### [Offline Password Manager](#offline-password-manager)

Password manager, stored on encrypted volume, which you only access from Live USB, which has no internet connection. It holds all critial credentials, which are not required during daily operation like AdminPIN, PUK, YubiKey PIV ManagementKey, Secure Boot Platform Key etc.

#

#### [3-2-1 Backup Rule](#3-2-1-backup-rule)

Backup rule saying you should always have at least **3** copies of your data, store **2** backup copies on different devices or storage media and keep at least **1** backup copy offsite.

#

#### [Snowflake](#snowflake)

Snowflake is servers/machines, which configuration has drifted from original or automated configuration. Such drift is not desired, as configuration of such machines are hard to reproduce, which makes the recovery process harded when machine breaks.

#

#### [Secure OS](#secure-os)

Operating System focused on security and privacy, for example [Tails](https://tails.boum.org/).

#

#### [GPG Master Key](#gpg-master-key)

GPG Master Key is a main source of trust for your GPG identity.
This key has only signing capabilities, it is used only to sign and revoke your [GPG sub-keys](#gpg-sub-keys) and it should only be stored on offline volumes to minimize the risk of leaking.

#

#### [GPG Sub-keys](#gpg-sub-keys)

GPG keys which are used on a daily basis. Usually it is a signing key, encryption key and authentication key. All 3 keys should be stored on Hardware security device.

#

#### [Master Password](#master-password)

Master password is the only password you must remember when following this guide.
This password is used for unlocking your daily password manager and to decrypt [Offline Backup Volumes](#offline-backup-volume).
This password should be long and complex to make sure it cannot be brute-forced.

#

#### [Offline Backup Volume](#offline-backup-volume)

Offline Backup Volume is a local storage device (e.g. Pendrive), encrypted using [Master Password](#master-password), which contains all secrets like [GPG Master Key](#gpg-master-key), which must be kept secure at all cost.
Accessing it's data should only be performed from [Secure OS](#secure-os) with no network access.

#

#### [Secure Boot Platform Key (PK)](#secure-boot-platform-key-pk)

Top level X.509 certificate with RSA key-pair used in Secure Boot process.
"Platform" in "Platform Key" refers to [Computing platform](https://en.wikipedia.org/wiki/Computing_platform), which can be
an actual piece of hardware you execute code on, but can also be a virtualized environment or a web browser.

Owning Platform Private Key allows you to proof to the UEFI that you are the physical owner of the hardware.

This trust is established by requiring physical presence to the unit (platform) to "take ownership", so to add initial PK.

If the attacker poseses the Platform Private Key and access to the hardware, it does not give them direct access to execute code on the platform, as one needs to execute code, which will add a malicious public key to the signature database.

Usually this key is populated with device manufacturer (OEM) key and it signs KEK keys, including Microsoft CA.

This guide assumes that you are platform owner, so as part of [Bootstrapping](#bootstrapping) process you will generate and roll your own Platform Key, which will later be stored on [Offline Backup Volume](#offline-backup-volume), as it is not required for daily operation.

#

#### [OS Recovery Volume](#os-recovery-volume)

Removable device, which contains your personalized Arch Linux installer.

#

#### [MFA/2FA - Multi/Two Factor Authentication](#mfa-2fa-multi-two-factor-authentication)



#

#### [MFA Recovery Token](#mfa-recovery)



#
