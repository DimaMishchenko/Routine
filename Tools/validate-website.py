import argparse
from html.parser import HTMLParser
import importlib.util
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit
from xml.etree import ElementTree


SPEC = importlib.util.spec_from_file_location("build_website", Path(__file__).with_name("build-website.py"))
BUILD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BUILD)
SITE_ORIGIN = BUILD.SITE_ORIGIN
PUBLIC_FILES = BUILD.PUBLIC_FILES
INDEXABLE_PAGES = BUILD.INDEXABLE_PAGES
APPLE_EULA = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"


class Page(HTMLParser):
    def __init__(self, content):
        super().__init__(convert_charrefs=True)
        self.ids = set()
        self.links = []
        self.canonicals = []
        self.alternates = {}
        self.picker_links = []
        self.picker_summaries = []
        self.picker_count = 0
        self.in_picker = False
        self.lang = None
        self.metadata = {}
        self.titles = []
        self.structured_data = []
        self.external_scripts = []
        self.capture = None
        self.feed(content)
        self.close()

    def handle_starttag(self, tag, attrs):
        if len(dict(attrs)) != len(attrs):
            raise ValueError(f"duplicate HTML attributes: {tag}")
        attrs = dict(attrs)
        if tag in {"base", "iframe", "object", "embed", "form", "footer"} or any(
            name.startswith("on") or name in {"srcdoc", "srcset"} for name in attrs
        ):
            raise ValueError(f"unsupported active or unvalidated HTML: {tag}")
        if tag == "html":
            if self.lang is not None:
                raise ValueError("duplicate html element")
            self.lang = attrs.get("lang")
        if tag == "title":
            self.titles.append("")
            self.capture = self.titles
        if tag == "script":
            if attrs == {"type": "application/ld+json"}:
                self.structured_data.append("")
                self.capture = self.structured_data
            elif set(attrs) == {"src", "defer"} and attrs["defer"] is None:
                self.external_scripts.append(attrs["src"])
            else:
                raise ValueError("only JSON-LD and the approved deferred local scripts are allowed")
        if tag == "meta":
            key = attrs.get("name", attrs.get("property", attrs.get("http-equiv", ""))).lower()
            if key in self.metadata:
                raise ValueError(f"duplicate metadata: {key}")
            self.metadata[key] = attrs.get("content", "")
        if tag == "link":
            relations = attrs.get("rel", "").split()
            if "canonical" in relations:
                self.canonicals.append(attrs.get("href", ""))
            if "alternate" in relations:
                language = attrs.get("hreflang", "")
                if language in self.alternates:
                    raise ValueError(f"duplicate alternate: {language}")
                self.alternates[language] = attrs.get("href", "")
        if tag == "details" and attrs.get("class") == "language-picker":
            self.picker_count += 1
            self.in_picker = True
        if tag == "a" and self.in_picker:
            self.picker_links.append(attrs)
        if tag == "summary" and self.in_picker:
            self.picker_summaries.append(attrs)
        if "id" in attrs:
            if attrs["id"] in self.ids:
                raise ValueError(f"duplicate HTML id: {attrs['id']}")
            self.ids.add(attrs["id"])
        for name in ("href", "src"):
            if attrs.get(name):
                self.links.append(attrs[name])

    def handle_data(self, data):
        if self.capture is not None:
            self.capture[-1] += data

    def handle_endtag(self, tag):
        if tag in {"title", "script"}:
            self.capture = None
        if tag == "details":
            self.in_picker = False


def validate_discovery(root, pages, catalogs):
    titles = {locale: set() for locale in BUILD.LOCALES}
    descriptions = {locale: set() for locale in BUILD.LOCALES}
    for filename, (locale, name) in INDEXABLE_PAGES.items():
        page = pages[filename]
        canonical = BUILD.page_url(locale, name)
        if page.lang != locale or page.canonicals != [canonical]:
            raise ValueError(f"{filename}: incorrect language or canonical")
        if len(page.titles) != 1 or not page.titles[0].strip():
            raise ValueError(f"{filename}: expected one nonempty title")
        title = page.titles[0].strip()
        description = page.metadata.get("description", "").strip()
        if not description or title in titles[locale] or description in descriptions[locale]:
            raise ValueError(f"{filename}: title and description must be page-specific")
        titles[locale].add(title)
        descriptions[locale].add(description)
        image = SITE_ORIGIN + "/assets/" + ("routine-devices.webp" if name == "index.html" else "routine-icon.webp")
        expected = {
            "og:type": "website", "og:site_name": catalogs[locale]["Routine"], "og:url": canonical,
            "og:locale": BUILD.LOCALES[locale][1], "og:title": title, "og:description": description,
            "og:image": image, "twitter:title": title, "twitter:description": description,
            "twitter:image": image, "twitter:card": "summary_large_image" if name == "index.html" else "summary",
        }
        for key, value in expected.items():
            if page.metadata.get(key) != value:
                raise ValueError(f"{filename}: missing or inconsistent {key}")
        if not page.metadata.get("og:image:alt", "").strip() or page.metadata.get("twitter:image:alt") != page.metadata["og:image:alt"]:
            raise ValueError(f"{filename}: expected matching social image descriptions")
        if any(key in page.metadata for key in {"robots", "googlebot", "bingbot", "refresh"}):
            raise ValueError(f"{filename}: indexable pages must not redirect or restrict crawlers")
        alternates = {target: BUILD.page_url(target, name) for target in BUILD.LOCALES}
        alternates["x-default"] = BUILD.page_url("en", name)
        if page.alternates != alternates:
            raise ValueError(f"{filename}: inconsistent reciprocal locale alternates")
        prefix = "" if locale == "en" else "../"
        if page.external_scripts != [prefix + "navigation.js?v=header-picker", prefix + "analytics.js?v=cloudflare-1"]:
            raise ValueError(f"{filename}: expected the deferred local navigation and analytics scripts exactly once")
        picker = [
            {"href": prefix + BUILD.page_file(target, name), "lang": target, "hreflang": target,
             **({"aria-current": "page"} if target == locale else {})}
            for target in BUILD.LOCALES
        ]
        if page.picker_count != 1 or page.picker_links != picker:
            raise ValueError(f"{filename}: expected same-page native language picker links")
        code = locale.split("-")[0].upper()
        if page.picker_summaries != [{
            "aria-label": code + " — " + catalogs[locale]["Language"] + ": " + BUILD.LOCALES[locale][0],
            "title": catalogs[locale]["Choose language"],
        }]:
            raise ValueError(f"{filename}: language picker accessible name must include its visible code")
        if name == "index.html":
            if len(page.structured_data) != 1:
                raise ValueError(f"{filename}: expected one JSON-LD graph")
            expected_data = BUILD.structured_data(locale, catalogs[locale]).split("\n", 1)[1].rsplit("\n", 1)[0]
            if json.loads(page.structured_data[0]) != json.loads(expected_data):
                raise ValueError(f"{filename}: inconsistent localized JSON-LD")
        elif page.structured_data:
            raise ValueError(f"{filename}: JSON-LD belongs only on homepages")
        page.links.append(image)

    terms = pages["terms.html"]
    if terms.lang != "en" or terms.canonicals != [APPLE_EULA] or terms.metadata.get("refresh") != "0; url=" + APPLE_EULA or APPLE_EULA not in terms.links:
        raise ValueError("terms.html: preserve the English Apple EULA redirect and fallback")
    if terms.structured_data or terms.external_scripts or terms.alternates or terms.picker_count:
        raise ValueError("terms.html: EULA redirect must not be localized or indexed")
    robots = (root / "robots.txt").read_text(encoding="utf-8").splitlines()
    if [line.strip() for line in robots if line.strip()] != [
        "User-agent: *", "Allow: /", "Sitemap: " + SITE_ORIGIN + "/sitemap.xml",
    ]:
        raise ValueError("robots.txt: expected unrestricted crawling and canonical sitemap")
    namespace = "{http://www.sitemaps.org/schemas/sitemap/0.9}"
    try:
        sitemap = ElementTree.fromstring((root / "sitemap.xml").read_text(encoding="utf-8"))
    except ElementTree.ParseError as error:
        raise ValueError(f"sitemap.xml: invalid XML: {error}") from None
    if sitemap.tag != namespace + "urlset":
        raise ValueError("sitemap.xml: expected a sitemap urlset")
    locations = []
    for entry in sitemap:
        if entry.tag != namespace + "url" or len(entry) != 1 or entry[0].tag != namespace + "loc":
            raise ValueError("sitemap.xml: expected canonical URL entries only")
        locations.append(entry[0].text)
    if len(locations) != 36 or set(locations) != {BUILD.page_url(locale, name) for locale, name in INDEXABLE_PAGES.values()}:
        raise ValueError("sitemap.xml: expected all 36 canonical URLs exactly once")


def validate(root, website=None, app_localizations=None):
    website = website or BUILD.REPOSITORY / "Website"
    app_localizations = app_localizations or BUILD.REPOSITORY / "Modules/RoutineApp/Resources/Localization"
    found = BUILD.public_inventory(root)
    if found != PUBLIC_FILES:
        raise ValueError(f"public file allowlist mismatch; missing={sorted(PUBLIC_FILES - found)}")
    catalogs, _ = BUILD.load_sources(website, app_localizations)
    pages = {name: Page((root / name).read_text(encoding="utf-8")) for name in sorted(PUBLIC_FILES) if name.endswith(".html")}
    validate_discovery(root, pages, catalogs)
    references = [(name, link) for name, page in pages.items() for link in page.links]
    css = (root / "styles.css").read_text(encoding="utf-8")
    references.extend(("styles.css", match[2].strip()) for match in re.finditer(r"url\(\s*(['\"]?)(.*?)\1\s*\)", css, re.IGNORECASE))
    for source, reference in references:
        url = urlsplit(reference)
        if url.scheme or url.netloc:
            if url.scheme not in {"https", "mailto", "tel"}:
                raise ValueError(f"{source}: unsupported URL: {reference}")
            if url.hostname == "dimamishchenko.github.io" and url.path.lower().startswith("/routine"):
                raise ValueError(f"{source}: stale project-domain URL: {reference}")
            if f"{url.scheme}://{url.netloc}" != SITE_ORIGIN:
                continue
            target = root / unquote(url.path.removeprefix("/"))
        else:
            if url.path.startswith("/"):
                raise ValueError(f"{source}: use project-relative links: {reference}")
            target = root / Path(source).parent / unquote(url.path or Path(source).name)
        if url.path.endswith("/") or (url.netloc and not url.path):
            target = target / "index.html"
        target = target.resolve()
        try:
            relative = target.relative_to(root.resolve()).as_posix()
        except ValueError:
            raise ValueError(f"{source}: link leaves public directory: {reference}") from None
        if relative not in PUBLIC_FILES:
            raise ValueError(f"{source}: missing local target: {reference}")
        if url.fragment and relative in pages and unquote(url.fragment) not in pages[relative].ids:
            raise ValueError(f"{source}: missing HTML fragment: {reference}")
    BUILD.check_generated(root, BUILD.generated_files(website, app_localizations))
    print(f"Website validated: {len(found)} public files, 36 pages, {len(references)} references")


def main():
    parser = argparse.ArgumentParser(description="Validate localized static GitHub Pages output and sources.")
    parser.add_argument("root", nargs="?", type=Path, default=BUILD.REPOSITORY / "Website/public")
    args = parser.parse_args()
    try:
        validate(args.root)
    except (ValueError, OSError) as error:
        print(f"Website validation failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
