# Routine website

A static information site with local system fonts, CSS and native previews using
fictional sample routines. No build step, vendor scripts or analytics are required.

## Preview

From the repository root:

```sh
python3 -m http.server 8861 --bind 127.0.0.1 --directory Website/public
```

Open [the local site](http://127.0.0.1:8861/). Serve only `public/`.

## Hosting

Hosting is not configured. Publishing requires the owner's approval of the final
content, URLs and host. Deploy only these eight ordinary files from `public/`:

```text
index.html
privacy.html
support.html
terms.html
styles.css
assets/routine-iphone.webp
assets/routine-mac.webp
assets/routine-icon.webp
```

Keep relative links working under `/Routine/`. Do not deploy repository documents,
source, credentials, raw captures or build artifacts. The README also uses the
preview images, so keep their paths stable.

Before publishing, check every page and asset, mobile layout, keyboard navigation,
release status and privacy/support wording. Preserve coverage for installed 1.0.4
copies while distinguishing the upcoming 1.1.0 update. Verify live HTTPS URLs
before replacing app or App Store support/privacy links.
