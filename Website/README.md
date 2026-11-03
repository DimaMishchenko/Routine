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

The site uses these thirteen ordinary files from `public/`:

```text
index.html
privacy.html
support.html
terms.html
styles.css
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
The validator checks the exact public file allowlist, rejects symbolic and hard
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
training-policy directives, executable scripts or analytics.

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
