# Security

Report sensitive vulnerabilities privately to [dimasike.dev@gmail.com](mailto:dimasike.dev@gmail.com).
Include the affected version, reproduction steps and likely impact. Do not post
credentials, personal routines or cloud data in public issues. Routine is in
maintenance mode, with no guaranteed response or fix schedule.

## Credentials and signing

Keep account tokens, certificates, provisioning profiles and private signing
material out of Git. Release signing uses Xcode's saved account and Keychain;
no Match repository or App Store Connect API private key is required.

If a credential is exposed, revoke it at the provider before removing it from the
repository. Deleting a file or rewriting history does not revoke credentials or
erase other clones, forks, caches and downloaded copies. Never reuse an exposed key.

## Repository protection

GitHub secret scanning and push protection are enabled for this repository.
These checks supplement careful credential handling; they do not establish
whether an exposed credential has been revoked at its provider.
