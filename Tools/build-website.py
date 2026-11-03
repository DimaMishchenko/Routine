import argparse
from html import escape
import json
from pathlib import Path
import re
import stat
import sys


REPOSITORY = Path(__file__).resolve().parents[1]
SITE_ORIGIN = "https://routine.dimasike.com"
LOCALES = {
    "bn": ("বাংলা", "bn_BD"),
    "de": ("Deutsch", "de_DE"),
    "en": ("English", "en_US"),
    "es": ("Español", "es_ES"),
    "fr": ("Français", "fr_FR"),
    "hi": ("हिन्दी", "hi_IN"),
    "id": ("Bahasa Indonesia", "id_ID"),
    "ja": ("日本語", "ja_JP"),
    "pt-BR": ("Português (Brasil)", "pt_BR"),
    "ru": ("Русский", "ru_RU"),
    "uk": ("Українська", "uk_UA"),
    "zh-Hans": ("简体中文", "zh_CN"),
}
PAGE_NAMES = ("index.html", "support.html", "privacy.html")
ASSETS = {
    "assets/routine-icon.webp", "assets/routine-iphone.webp", "assets/routine-ipad.webp",
    "assets/routine-mac.webp", "assets/routine-devices.webp", "assets/download-on-the-app-store.svg",
}
STATIC_FILES = ASSETS | {"styles.css", "navigation.js", "analytics.js", "terms.html", "robots.txt"}
APP_DESCRIPTION = "A habit tracker for iPhone, iPad and Mac with flexible goals, progress history, reminders and iCloud sync."
TRANSLATION = re.compile(r'\{\{t:("(?:[^"\\]|\\.)*")\}\}')
VARIABLE = re.compile(r"\{\{([a-z_]+)\}\}")
TOKEN = re.compile(TRANSLATION.pattern + "|" + VARIABLE.pattern)


def page_file(locale, name):
    return name if locale == "en" else f"{locale}/{name}"


def page_url(locale, name):
    prefix = "/" if locale == "en" else f"/{locale}/"
    return SITE_ORIGIN + prefix + ("" if name == "index.html" else name)


INDEXABLE_PAGES = {
    page_file(locale, name): (locale, name)
    for locale in LOCALES for name in PAGE_NAMES
}
PUBLIC_FILES = STATIC_FILES | set(INDEXABLE_PAGES) | {"sitemap.xml"}


def ordinary_file(path):
    info = path.lstat()
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
        raise ValueError(f"not an ordinary file (or is a hard link): {path}")


def public_inventory(root):
    if root.is_symlink() or not root.is_dir():
        raise ValueError(f"public root must be an ordinary directory: {root}")
    found = set()
    directories = {"assets"} | (set(LOCALES) - {"en"})
    for path in root.rglob("*"):
        relative = path.relative_to(root).as_posix()
        info = path.lstat()
        if stat.S_ISDIR(info.st_mode) and relative in directories:
            continue
        ordinary_file(path)
        found.add(relative)
    if found - PUBLIC_FILES:
        raise ValueError(f"unexpected public files: {sorted(found - PUBLIC_FILES)}")
    return found


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate catalog key: {key}")
        result[key] = value
    return result


def load_sources(website, app_localizations):
    folders = {path.stem for path in app_localizations.glob("*.lproj") if path.is_dir()}
    if folders != set(LOCALES):
        raise ValueError(f"app locale coverage mismatch: {sorted(folders)}")
    directory = website / "locales"
    if directory.is_symlink() or not directory.is_dir():
        raise ValueError("catalog directory must be an ordinary directory")
    paths = {path.name: path for path in directory.iterdir()}
    expected = {locale + ".json" for locale in LOCALES}
    if set(paths) != expected:
        raise ValueError(f"catalog coverage mismatch; missing={sorted(expected - set(paths))}, unexpected={sorted(set(paths) - expected)}")
    catalogs = {}
    for locale in LOCALES:
        path = paths[locale + ".json"]
        ordinary_file(path)
        catalog = json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
        if not isinstance(catalog, dict) or not catalog or any(
            not isinstance(value, str) or not value.strip() for value in catalog.values()
        ):
            raise ValueError(f"{locale}: catalog must map messages to nonempty plain text")
        catalogs[locale] = catalog
    english = catalogs["en"]
    if any(key != value for key, value in english.items()):
        raise ValueError("English catalog must map each English msgid to itself")
    for locale, catalog in catalogs.items():
        if set(catalog) != set(english):
            raise ValueError(f"{locale}: catalog parity mismatch; missing={sorted(set(english) - set(catalog))}, unknown={sorted(set(catalog) - set(english))}")
    templates = {}
    for name in PAGE_NAMES:
        path = website / "templates" / name
        ordinary_file(path)
        templates[name] = path.read_text(encoding="utf-8")
        if "{{" in TOKEN.sub("", templates[name]) or "}}" in TOKEN.sub("", templates[name]):
            raise ValueError(f"{name}: malformed template token")
    messages = {json.loads(match[1]) for template in templates.values() for match in TRANSLATION.finditer(template)}
    messages |= {APP_DESCRIPTION, "Language", "Choose language", "Main navigation", "GitHub", "Support", "Privacy"}
    if messages != set(english):
        raise ValueError(f"template message contract mismatch; missing={sorted(set(english) - messages)}, unknown={sorted(messages - set(english))}")
    return catalogs, templates


def structured_data(locale, catalog):
    canonical = page_url(locale, "index.html")
    data = {
        "@context": "https://schema.org",
        "@graph": [
            {"@type": "WebSite", "@id": canonical + "#website", "name": catalog["Routine"],
             "url": canonical, "inLanguage": locale},
            {"@type": "SoftwareApplication", "@id": canonical + "#app", "name": catalog["Routine"],
             "url": canonical, "inLanguage": locale, "description": catalog[APP_DESCRIPTION],
             "applicationCategory": "LifestyleApplication", "operatingSystem": "iOS, iPadOS, macOS",
             "image": SITE_ORIGIN + "/assets/routine-devices.webp"},
        ],
    }
    encoded = json.dumps(data, ensure_ascii=False, indent=2)
    encoded = encoded.replace("&", "\\u0026").replace("<", "\\u003c").replace(">", "\\u003e")
    return '<script type="application/ld+json">\n' + encoded + '\n  </script>'


def language_picker(locale, name, catalog):
    prefix = "" if locale == "en" else "../"
    code = locale.split("-")[0].upper()
    links = []
    for target, (autonym, _) in LOCALES.items():
        current = ' aria-current="page"' if target == locale else ""
        href = prefix + page_file(target, name)
        links.append(f'        <li><a href="{href}" lang="{target}" hreflang="{target}"{current}>{escape(autonym)}</a></li>')
    return (
        '<details class="language-picker">\n'
        f'      <summary aria-label="{escape(code + " — " + catalog["Language"] + ": " + LOCALES[locale][0], quote=True)}" '
        f'title="{escape(catalog["Choose language"], quote=True)}">{code}</summary>\n'
        '      <ul>\n' + "\n".join(links) + '\n      </ul>\n    </details>'
    )


def site_navigation(name, catalog):
    label = escape(catalog["Main navigation"], quote=True)
    links = []
    for href, message in (
        ("support.html", "Support"), ("privacy.html", "Privacy"),
    ):
        current = ' aria-current="page"' if href == name else ""
        links.append(f'<a href="{href}"{current}>{escape(catalog[message])}</a>')
    content = "".join(links)
    return (
        f'<nav class="primary-nav" aria-label="{label}">{content}</nav>\n'
        '      <details class="site-menu">\n'
        f'        <summary aria-label="{label}"><span aria-hidden="true">⋯</span></summary>\n'
        f'        <nav aria-label="{label}">{content}</nav>\n'
        '      </details>'
    )


def github_link(catalog):
    label = escape(catalog["GitHub"], quote=True)
    return (
        f'<a class="github-link" href="https://github.com/DimaMishchenko/Routine" aria-label="{label}" title="{label}">'
        '<svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true" focusable="false">'
        '<path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 '
        '0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53'
        '.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 '
        '0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82a7.65 7.65 0 0 1 2-.27c.68 0 '
        '1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 '
        '0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 '
        '8.01 0 0 0 16 8c0-4.42-3.58-8-8-8Z"/></svg></a>'
    )


def generated_files(website, app_localizations):
    catalogs, templates = load_sources(website, app_localizations)
    result = {}
    for locale, catalog in catalogs.items():
        for name, template in templates.items():
            variables = {
                "locale": locale, "og_locale": LOCALES[locale][1],
                "canonical": page_url(locale, name), "asset_prefix": "" if locale == "en" else "../",
                "alternates": "\n".join(
                    f'  <link rel="alternate" hreflang="{target}" href="{page_url(target, name)}">'
                    for target in LOCALES
                ) + f'\n  <link rel="alternate" hreflang="x-default" href="{page_url("en", name)}">',
                "structured_data": structured_data(locale, catalog),
                "language_picker": language_picker(locale, name, catalog),
                "site_navigation": site_navigation(name, catalog),
                "github_link": github_link(catalog),
            }
            def replace_token(match):
                if match[1] is not None:
                    return escape(catalog[json.loads(match[1])], quote=True)
                if match[2] not in variables:
                    raise ValueError(f"unknown template variable: {match[2]}")
                return variables[match[2]]
            content = TOKEN.sub(replace_token, template)
            result[page_file(locale, name)] = content.encode("utf-8")
    locations = "\n".join(
        f"  <url><loc>{page_url(locale, name)}</loc></url>"
        for locale, name in INDEXABLE_PAGES.values()
    )
    result["sitemap.xml"] = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + locations + '\n</urlset>\n'
    ).encode("utf-8")
    return result


def check_generated(root, generated):
    found = public_inventory(root)
    if found != PUBLIC_FILES:
        raise ValueError(f"public file allowlist mismatch; missing={sorted(PUBLIC_FILES - found)}")
    drift = [name for name, content in generated.items() if (root / name).read_bytes() != content]
    if drift:
        raise ValueError(f"generated files drift; run python3 Tools/build-website.py: {', '.join(drift)}")


def main():
    parser = argparse.ArgumentParser(description="Generate every app locale from plain-text catalogs.")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        website = REPOSITORY / "Website"
        root = website / "public"
        generated = generated_files(website, REPOSITORY / "Modules/RoutineApp/Resources/Localization")
        if args.check:
            check_generated(root, generated)
        else:
            found = public_inventory(root)
            if STATIC_FILES - found:
                raise ValueError(f"missing static files: {sorted(STATIC_FILES - found)}")
            for name, content in generated.items():
                target = root / name
                target.parent.mkdir(exist_ok=True)
                target.write_bytes(content)
        print(f"Website {'checked' if args.check else 'generated'}: 12 locales, 36 indexable pages")
    except (ValueError, OSError) as error:
        print(f"Website generation failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
