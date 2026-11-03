import argparse
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import stat
import sys
from urllib.parse import unquote, urlsplit
from xml.etree import ElementTree


PUBLIC_FILES = {
    "index.html", "privacy.html", "support.html", "terms.html", "styles.css",
    "assets/routine-icon.webp", "assets/routine-iphone.webp", "assets/routine-ipad.webp",
    "assets/routine-mac.webp", "assets/routine-devices.webp",
    "assets/download-on-the-app-store.svg",
    "robots.txt", "sitemap.xml",
}
SITE_ORIGIN = "https://routine.dimasike.com"
INDEXABLE_PAGES = {"index.html": "/", "privacy.html": "/privacy.html", "support.html": "/support.html"}
APPLE_EULA = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"


class Page(HTMLParser):
    def __init__(self, content):
        super().__init__(convert_charrefs=True)
        self.ids = set()
        self.links = []
        self.canonicals = []
        self.metadata = {}
        self.titles = []
        self.structured_data = []
        self.capture = None
        self.feed(content)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "title":
            self.titles.append("")
            self.capture = self.titles
        if tag == "script":
            if attrs.get("type") != "application/ld+json":
                raise ValueError("only JSON-LD scripts are allowed")
            self.structured_data.append("")
            self.capture = self.structured_data
        if tag == "meta":
            key = attrs.get("name", attrs.get("property", attrs.get("http-equiv", ""))).lower()
            if key in self.metadata:
                raise ValueError(f"duplicate metadata: {key}")
            self.metadata[key] = attrs.get("content", "")
        if tag == "link" and "canonical" in attrs.get("rel", "").split():
            self.canonicals.append(attrs.get("href", ""))
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


def validate_discovery(root, pages):
    titles = set()
    descriptions = set()
    for name, site_path in INDEXABLE_PAGES.items():
        page = pages[name]
        canonical = SITE_ORIGIN + site_path
        if page.canonicals != [canonical]:
            raise ValueError(f"{name}: expected canonical {canonical}")
        if len(page.titles) != 1 or not page.titles[0].strip():
            raise ValueError(f"{name}: expected one nonempty title")
        title = page.titles[0].strip()
        description = page.metadata.get("description", "").strip()
        if not description or title in titles or description in descriptions:
            raise ValueError(f"{name}: title and description must be nonempty and page-specific")
        titles.add(title)
        descriptions.add(description)
        image = SITE_ORIGIN + "/assets/" + (
            "routine-devices.webp" if name == "index.html" else "routine-icon.webp"
        )
        expected = {
            "og:type": "website", "og:site_name": "Routine", "og:url": canonical,
            "og:title": title, "og:description": description, "og:image": image,
            "twitter:title": title, "twitter:description": description, "twitter:image": image,
            "twitter:card": "summary_large_image" if name == "index.html" else "summary",
        }
        for key, value in expected.items():
            if page.metadata.get(key) != value:
                raise ValueError(f"{name}: missing or inconsistent {key}")
        if not page.metadata.get("og:image:alt", "").strip() or (
            page.metadata.get("twitter:image:alt") != page.metadata["og:image:alt"]
        ):
            raise ValueError(f"{name}: expected matching social image descriptions")
        if any(key in page.metadata for key in {"robots", "googlebot", "bingbot", "refresh"}):
            raise ValueError(f"{name}: keep indexable pages free of crawler directives and redirects")
        page.links.append(image)

    homepage = pages["index.html"]
    if len(homepage.structured_data) != 1:
        raise ValueError("index.html: expected one JSON-LD document")
    data = json.loads(homepage.structured_data[0])
    if not isinstance(data, dict) or set(data) != {"@context", "@graph"} or data["@context"] != "https://schema.org":
        raise ValueError("index.html: expected a schema.org JSON-LD graph")
    graph = data["@graph"]
    if not isinstance(graph, list) or len(graph) != 2:
        raise ValueError("index.html: expected WebSite and SoftwareApplication nodes")
    schemas = {
        "WebSite": {"@type", "@id", "name", "url", "inLanguage"},
        "SoftwareApplication": {
            "@type", "@id", "name", "url", "description", "applicationCategory", "operatingSystem", "image",
        },
    }
    remaining = set(schemas)
    for node in graph:
        if not isinstance(node, dict) or not isinstance(node.get("@type"), str) or node["@type"] not in remaining:
            raise ValueError("index.html: unexpected or duplicate JSON-LD node")
        kind = node["@type"]
        remaining.remove(kind)
        if set(node) != schemas[kind] or any(not isinstance(value, str) or not value.strip() for value in node.values()):
            raise ValueError("index.html: keep JSON-LD descriptive, without release, offer or rating claims")
        identifier = "website" if kind == "WebSite" else "app"
        if node["name"] != "Routine" or node["url"] != SITE_ORIGIN + "/" or node["@id"] != SITE_ORIGIN + "/#" + identifier:
            raise ValueError("index.html: inconsistent JSON-LD identity")
        if kind == "WebSite" and node["inLanguage"] != "en":
            raise ValueError("index.html: expected English WebSite metadata")
        if kind == "SoftwareApplication":
            if node["operatingSystem"] != "iOS, iPadOS, macOS" or node["applicationCategory"] != "LifestyleApplication":
                raise ValueError("index.html: unexpected application platform or category")
            if node["image"] != homepage.metadata["og:image"]:
                raise ValueError("index.html: inconsistent JSON-LD image")
    if any(page.structured_data for name, page in pages.items() if name != "index.html"):
        raise ValueError("JSON-LD belongs only on the homepage")

    terms = pages["terms.html"]
    if terms.canonicals != [APPLE_EULA] or terms.metadata.get("refresh") != "0; url=" + APPLE_EULA or APPLE_EULA not in terms.links:
        raise ValueError("terms.html: preserve the Apple EULA canonical, redirect and fallback link")

    robots = (root / "robots.txt").read_text(encoding="utf-8").splitlines()
    if [line.strip() for line in robots if line.strip()] != [
        "User-agent: *", "Allow: /", "Sitemap: " + SITE_ORIGIN + "/sitemap.xml",
    ]:
        raise ValueError("robots.txt: expected unrestricted crawling and canonical sitemap")
    try:
        sitemap = ElementTree.fromstring((root / "sitemap.xml").read_text(encoding="utf-8"))
    except ElementTree.ParseError as error:
        raise ValueError(f"sitemap.xml: invalid XML: {error}") from None
    namespace = "{http://www.sitemaps.org/schemas/sitemap/0.9}"
    if sitemap.tag != namespace + "urlset":
        raise ValueError("sitemap.xml: expected a sitemap urlset")
    locations = []
    for entry in sitemap:
        if entry.tag != namespace + "url" or len(entry) != 1 or entry[0].tag != namespace + "loc":
            raise ValueError("sitemap.xml: expected canonical URL entries only")
        locations.append(entry[0].text)
    if len(locations) != len(INDEXABLE_PAGES) or set(locations) != {
        SITE_ORIGIN + site_path for site_path in INDEXABLE_PAGES.values()
    }:
        raise ValueError("sitemap.xml: expected each indexable canonical URL exactly once")


def validate(root):
    if root.is_symlink() or not root.is_dir():
        raise ValueError(f"public root must be an ordinary directory: {root}")
    found = set()
    for path in root.rglob("*"):
        relative = path.relative_to(root).as_posix()
        info = path.lstat()
        if stat.S_ISDIR(info.st_mode) and relative == "assets":
            continue
        if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
            raise ValueError(f"not an ordinary file (or is a hard link): {relative}")
        found.add(relative)
    if found != PUBLIC_FILES:
        raise ValueError(
            f"public file allowlist mismatch; missing={sorted(PUBLIC_FILES - found)}, "
            f"unexpected={sorted(found - PUBLIC_FILES)}"
        )

    pages = {
        name: Page((root / name).read_text(encoding="utf-8"))
        for name in sorted(PUBLIC_FILES) if name.endswith(".html")
    }
    validate_discovery(root, pages)
    references = [(name, link) for name, page in pages.items() for link in page.links]
    css = (root / "styles.css").read_text(encoding="utf-8")
    references.extend(
        ("styles.css", match.group(2).strip())
        for match in re.finditer(r"url\(\s*(['\"]?)(.*?)\1\s*\)", css, re.IGNORECASE)
    )
    for source, reference in references:
        url = urlsplit(reference)
        if url.scheme or url.netloc:
            if url.scheme not in {"https", "mailto", "tel"}:
                raise ValueError(f"{source}: unsupported URL: {reference}")
            if url.hostname == "dimamishchenko.github.io" and url.path.lower().startswith("/routine"):
                raise ValueError(f"{source}: stale project-domain URL: {reference}")
            if f"{url.scheme}://{url.netloc}" != SITE_ORIGIN:
                continue
            target = root / unquote(url.path.removeprefix("/") or "index.html")
        else:
            if url.path.startswith("/"):
                raise ValueError(f"{source}: use project-relative links: {reference}")
            target = root / Path(source).parent / unquote(url.path or Path(source).name)
        target = target.resolve()
        try:
            relative = target.relative_to(root.resolve()).as_posix()
        except ValueError:
            raise ValueError(f"{source}: link leaves public directory: {reference}") from None
        if relative not in PUBLIC_FILES:
            raise ValueError(f"{source}: missing local target: {reference}")
        if url.fragment and relative in pages and unquote(url.fragment) not in pages[relative].ids:
            raise ValueError(f"{source}: missing HTML fragment: {reference}")
    print(f"Website validated: {len(found)} public files, {len(references)} references")


def main():
    parser = argparse.ArgumentParser(description="Validate the static GitHub Pages payload.")
    parser.add_argument(
        "root", nargs="?", type=Path,
        default=Path(__file__).resolve().parents[1] / "Website/public",
    )
    args = parser.parse_args()
    try:
        validate(args.root)
    except (ValueError, OSError) as error:
        print(f"Website validation failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
