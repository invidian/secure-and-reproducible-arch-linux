### Requirements

This guide requires the following hardware:

<dl>
  <dt>1 x (or more) x86 Computer with UEFI, Secure Boot and TPM support</dt>
  <dd>This guides assumes you have personal machine which will be used for daily operation. The guide also supports customized installation for each machine if you have more than one. The machine can be as well virtual machine.</dd>
  <dt>2 x Hardware security device with PIV, OpenPGP and OATH - HOTP like [YubiKey 5 Series](https://www.yubico.com/products/compare-yubikey-5-series/)</dt>
  <dd>The main point of this guide is to make use of hardware security device as much as possible. Two devices are required so one can be kept in secure place as a backup in case primary one is lost, stolen or damaged.</dd>
  <dt>2 x Dedicated removable storage device (e.g. pendrive) for offline backup of master keys and passwords</dt>
  <dd>Some secrets generated as part of this guide (e.g. GPG master key) should be kept on always offline volume to maximize their security. To ensure redundancy for those volumes, it is recommended to have at least 2 copies of them, to be able to handle situation when one of them gets corrupted or simply breaks.</dd>
  <dt>1 x (or more) dedicated removable storage device (e.g. pendrive) for a OS recovery volume</dt>
  <dd>This guide assumes data stored on daily computer is either version controlled, reproducible or regularly backed up into local storage. This means it should be possible and it is recommended to be able to re-install the OS on machine at any time. To be able to do that, one should always keep a dedicated OS recovery volume, which is capable of performing fully automated OS installation.</dd>
  <dt>2 x Temporary removable storage device (e.g. pendrive) for booting Secure OS and temporary storage</dt>
  <dd>As part of bootstrapping process and in case of some incidents, it is recommended to have two storage devices from which one can be formatted to allow installing Secure OS (e.g. Tails) on it and other to be able to store files when rebooting machine from OS connected to the internet to offline mode.</dd>
  <dt>1 x Dedicated removable storage device (e.g. USB HDD, network disk) for local backups</dt>
  <dd>Following [3-2-1 Backup Rule](#3-2-1-backup-rule) and to be able to quickly restore your last backup (restoring from local disk will be faster than restoring from internet), it is recommended to have a local storage available, which do not require internet access.</dd>
  <dt>1 x Dedicated S3-compatible remote storage server (e.g. Minio instance, AWS S3) for remote backups</dt>
  <dd>Again, following [3-2-1 Backup Rule](#3-2-1-backup-rule), to keep your backups geographically secure, it is recommended to have a remote storage server for keeping another copy of your backups, in case when both active copy and local backup gets damaged (e.g. in apartment fire). </dd>
</dl>

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
  <dd>Backup rule saying you should always have at least **3** copies of your data, store **2** backup copies on different devices or storage media and keep at least **1** backup copy offsite.</dd>
</dl>
