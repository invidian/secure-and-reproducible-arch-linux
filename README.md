#### Credentials which shouldn't be stored in [Daily Password Manager](#daily_password_manager)

This section contains list of credentials which are recommended to not be stored in [Daily Password Manager](#daily_password_manager),
as storing them there may have security implications.

<dl>
  <dt>2FA Recovery Codes</dt>
  <dd>It is not recommended to keep 2FA Recovery Codes in your Daily Password Manager, because if content of your Daily Password Manager leaks, it allows an attacker to bypass the requirement of your YubiKey to log in into 2FA enabled services.</dd>
</dl>

#### Glossary

<dl>
  <dt name="daily_password_manager">Daily Password Manager</dt>
  <dd>Password manager, which you use for every day logging in on your end devices like laptop or smartphone. This guide use KeePassXC, as it supports YubiKeys as a factor for unlocking the password database.</dd>
</dl>
