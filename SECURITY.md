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

## Local checks

```sh
make secrets
make secrets-history
```

The scanner checks a small set of high-confidence private-key and token formats,
redacts values and makes no network requests. The history mode inspects all locally
stored Git blobs, including unreachable objects. It is not an entropy scanner and
cannot establish provider revocation or inspect remote copies, CI logs or caches.

Before source publication, review a fresh intended publication clone and confirm
that any previously exposed credentials are revoked. Review public documentation,
assets and repository history as well as the latest working tree.
