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

GitHub Pages serves [the website](https://dimamishchenko.github.io/Routine/).
In repository **Settings → Pages → Build and deployment**, set **Source** to
**GitHub Actions**. The `Website` workflow validates every pull request and push
to `main`, then deploys successful pushes to `main`. It can also be run manually
from `main` in Actions. Restrict the `github-pages` environment to `main`.

The stable `Website` check can be required in branch protection. Pull requests,
including forks, run validation with read-only permissions and cannot deploy.
Only the deploy job receives Pages and OIDC write permissions. App signing,
TestFlight and App Store deployment remain local.

Only these eight ordinary files from `public/` are published:

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

Run `python3 Tools/validate-website.py` from the repository root before pushing.
The validator checks the exact public file allowlist, rejects symbolic and hard
links, and verifies local HTML/CSS targets and HTML fragments. Update the allowlist
deliberately when adding public files. External URLs are not fetched by this check.

Before publishing, check every page and asset, mobile layout, keyboard navigation,
release status and privacy/support wording. Preserve coverage for installed 1.0.4
copies while distinguishing the upcoming 1.1.0 update. Verify live HTTPS URLs
before replacing app or App Store support/privacy links.
