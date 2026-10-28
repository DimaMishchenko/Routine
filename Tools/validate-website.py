import argparse
from html.parser import HTMLParser
from pathlib import Path
import re
import stat
import sys
from urllib.parse import unquote, urlsplit


PUBLIC_FILES = {
    "index.html", "privacy.html", "support.html", "terms.html", "styles.css",
    "assets/routine-icon.webp", "assets/routine-iphone.webp", "assets/routine-mac.webp",
}
SITE_ORIGIN = "https://dimamishchenko.github.io"
SITE_PATH = "/Routine/"


class Page(HTMLParser):
    def __init__(self, content):
        super().__init__(convert_charrefs=True)
        self.ids = set()
        self.links = []
        self.feed(content)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "id" in attrs:
            if attrs["id"] in self.ids:
                raise ValueError(f"duplicate HTML id: {attrs['id']}")
            self.ids.add(attrs["id"])
        for name in ("href", "src"):
            if attrs.get(name):
                self.links.append(attrs[name])


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
            if f"{url.scheme}://{url.netloc}" != SITE_ORIGIN:
                continue
            if not url.path.startswith(SITE_PATH):
                raise ValueError(f"{source}: URL leaves /Routine/: {reference}")
            target = root / unquote(url.path[len(SITE_PATH):] or "index.html")
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
