# Routine website

A static information site with local system fonts, CSS and native previews using
fictional sample routines. Python's standard library builds localized HTML from
plain-text catalogs. Generation needs no external dependencies. Production pages
use the explicitly configured Cloudflare Web Analytics beacon.

## Localized sources and generation

`locales/en.json` owns the English message contract: English msgid to identical
English plain text. Every other catalog must contain exactly the same keys and
nonempty translated strings. `templates/` owns the approved homepage, support
and privacy markup. `{{t:"English msgid"}}` inserts HTML-escaped plain text in
text or attribute contexts, never translated HTML. JSON-LD is serialized separately
with escaped HTML delimiters, including its translated SoftwareApplication
description. Keep the catalog message set and template usage synchronized.

The locale set must exactly match
`Modules/RoutineApp/Resources/Localization/*.lproj`: `bn`, `de`, `en`, `es`, `fr`,
`hi`, `id`, `ja`, `pt-BR`, `ru`, `uk`, `zh-Hans`. The builder fails before writing
anything if a catalog is absent, malformed, incomplete or contains unknown or
duplicate keys. There is no English fallback or placeholder publication.

```sh
python3 Tools/build-website.py
python3 Tools/build-website.py --check
python3 Tools/validate-website.py
```

Commit generated pages alongside source changes. `--check` never writes and fails
on byte-level drift, missing output or unexpected public files. The validator also
checks this source-to-output match. CI checks generated output rather than silently
rebuilding it, and validates the deploy job's checked-out payload before upload.

English home/support/privacy stay at the root; the eleven other locales use
`/{locale}/`, `/{locale}/support.html` and `/{locale}/privacy.html`. The sitemap has
exactly 36 indexable canonical URLs. Every page declares its language, OG locale
and reciprocal full hreflang set, including itself and English `x-default`.
Home JSON-LD uses the page's language, canonical URL and translated description.
The root-only `terms.html` remains the existing English Apple EULA redirect.

A compact header `details` picker shows the current language code and opens a
two-column list of autonyms with same-page links. It works without JavaScript;
the local deferred `navigation.js` adds outside-click and Escape dismissal and
closes the other header popup when one opens. It uses no automatic redirects,
cookies, storage or analytics. Controls have 44px minimum targets; narrow screens
place Support and Privacy in a separate compact menu to keep the header on one line.
GitHub uses an accessible icon link beside the language picker on every screen size.
The shared composition and official badge stay English and unchanged; alt and
social descriptions come from each catalog. There is no footer.

## Preview

From the repository root:

```sh
python3 -m http.server 8861 --bind 127.0.0.1 --directory Website/public
```

Open [the local site](http://127.0.0.1:8861/). Serve only `public/`.

## Hosting

The intended canonical website is [routine.dimasike.com](https://routine.dimasike.com/).
Source preparation does not confirm that DNS, the custom domain or HTTPS is live.
In repository **Settings → Pages → Build and deployment**, set **Source** to
**GitHub Actions**. The `Website` workflow validates every pull request and push
to `main`, then deploys successful pushes to `main`. It can also be run manually
from `main` in Actions. Restrict the `github-pages` environment to `main`.

The stable `Website` check can be required in branch protection. Pull requests,
including forks, run validation with read-only permissions and cannot deploy.
Only the deploy job receives Pages and OIDC write permissions. App signing,
TestFlight and App Store deployment remain local.

### Custom-domain setup (repository/domain owner)

1. In repository **Settings → Pages → Custom domain**, save `routine.dimasike.com`
   before changing DNS. Keep the GitHub Actions deployment source.
2. At the DNS provider, point the `routine` subdomain's CNAME directly to
   `dimamishchenko.github.io`, not to a repository path or another custom domain.
   Resolve any conflicting records for that subdomain. Domain ownership
   verification, if requested by GitHub, is a separate owner-managed step.
3. Wait for GitHub's DNS check and certificate provisioning, then enable
   **Enforce HTTPS** when available. Do not assume a successful Actions run means
   the domain or certificate is ready.
4. Publish the approved source through the existing `Website` Actions workflow
   on `main`. Check the deployed artifact and deployment result.

Do not rely on a `CNAME` file: GitHub Pages ignores it for custom Actions
deployments. Repository Pages settings own the custom domain. No `CNAME` file
is included in the public allowlist. These instructions do not change cloud
configuration or publish the local working tree.

The exact public allowlist contains 48 ordinary files: these root/shared files
plus three generated HTML pages in each of the eleven non-English directories:

```text
index.html
privacy.html
support.html
terms.html
styles.css
navigation.js
analytics.js
robots.txt
sitemap.xml
assets/routine-iphone.webp
assets/routine-mac.webp
assets/routine-ipad.webp
assets/routine-icon.webp
assets/routine-devices.webp
assets/download-on-the-app-store.svg
```

Keep local navigation and asset links relative so previews still work; absolute
canonical and social URLs use the custom-domain root, not `/Routine/`.
Do not deploy repository documents,
source, credentials, raw captures or build artifacts. The README also uses the
preview images, so keep their paths stable.

Run `python3 Tools/validate-website.py` from the repository root before pushing.
The validator checks exact app/catalog locale coverage and message parity,
same-page picker links, reciprocal alternate targets and generated-file drift.
It checks the exact public file/directory allowlist, rejects symbolic and hard
links, and verifies local HTML/CSS targets and HTML fragments. It also checks
page-specific titles/descriptions, custom-domain canonicals, consistent OG/Twitter
metadata and local social images, the descriptive homepage JSON-LD, unrestricted
robots policy, sitemap membership, and the legacy Apple EULA redirect/fallback.
Update the allowlist deliberately when adding public files. External URLs are not
fetched by this check; it cannot verify DNS, HTTPS, App Store availability,
indexing or social-preview rendering.

The homepage uses one transparent composition with genuine MacBook, iPad and
iPhone frames, displayed without cropping, stretching or CSS-drawn devices.
The separate device assets remain available for the repository README and source
reference. Keep the validator’s public file allowlist in sync with these assets
before publishing.

## Discoverability and release cautions

The approved redesign is prepared for custom-domain deployment. Preserve its
rounded light design, single genuine framed composite, one-line mobile header,
official App Store badge, spacing and absence of a footer.

The homepage, Privacy and Support pages have distinct metadata and are the only
sitemap entries. `terms.html` deliberately canonicalizes and redirects to Apple’s
standard EULA, with a plain-link fallback; do not promote it as a second terms
document. Homepage `WebSite` and `SoftwareApplication` JSON-LD describe the public
content without ratings, offers, download availability or release-version claims.
The social images reuse the genuine composite and icon; check actual platform
previews because image-format support and cropping can vary.

Ordinary crawlable HTML, working links, canonical URLs and a sitemap are the
discoverability foundation. No special AI file is required; `llms.txt` is omitted.
Neither metadata nor an optional AI summary file guarantees rankings, indexing,
AI inclusion or rich results. Crawlers remain allowed; there are no new
training-policy directives. Page content and language links remain static HTML.
The local header-menu enhancement and analytics loader are the only executable
scripts included in the page source. The loader adds Cloudflare's exact account
beacon only on HTTPS `routine.dimasike.com`, never localhost, HTTP or previews.
The public ingestion token is not an API credential. Website analytics is separate
from the app, which does not include developer analytics. Each localized privacy
page discloses website analytics. Keep manual snippet installation enabled for
the Routine analytics registration to avoid duplicate automatic injection.

At the November 3, 2026 source review, version 1.1.0 (build 24) had not shipped
and the app was removed from sale. The homepage download link uses the app’s configured
App Store ID, `1643340709`, with Apple’s unmodified official English download badge
from `https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg`.
Apple
returned HTTP 404 for that URL when checked on November 3, 2026; the historical
check is not a fresh availability test. Verify public availability separately and
do not claim a release or store availability from a website deployment. Adding
the link does not restore availability. The privacy page describes 1.1.0 only.

Before publishing, check every page and asset, mobile layout, keyboard navigation,
release status and privacy/support wording. After publishing, verify HTTPS returns
the intended HTML at `/`, `/privacy.html` and `/support.html`, plus the actual
social image assets, `/robots.txt` and `/sitemap.xml`. Check canonical/social URLs
in served source, confirm the old Pages URL redirects to the custom domain without
a loop, and confirm `/terms.html` reaches Apple with a usable fallback link.
Check certificate validity and HTTP-to-HTTPS behavior. Only then consider submitting
the sitemap in owner-managed Google Search Console/Bing Webmaster Tools; submission
does not guarantee indexing. Verify live HTTPS URLs before replacing app or App
Store support/privacy links. Those settings and external verification are parent-owned.
