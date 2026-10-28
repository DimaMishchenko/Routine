import argparse
import collections
import html
import json
import os
from pathlib import Path

parser = argparse.ArgumentParser(description='Build a local native/artwork comparison gallery from renderer manifests.')
parser.add_argument('manifests', nargs='+', type=Path)
parser.add_argument('--output', type=Path, default=Path('.artifacts/modernization/store-package'))
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
cards, missing = [], []
for path in args.manifests:
    manifest = json.loads(path.read_text())
    cards.extend(manifest['cards'])
    missing.extend(manifest['missing'])
assert len({(c['device'], c['locale'], c['screen']) for c in cards}) == len(cards), 'Duplicate card slots'
def link(path):
    return html.escape(os.path.relpath(Path(path).resolve(), args.output.resolve()), quote=True)
groups = collections.defaultdict(list)
for card in cards:
    groups[(card['device'], card['locale'])].append(card)
parts = ['<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Routine screenshot review</title><style>body{font:16px system-ui;margin:32px;background:#f3f7ff;color:#13243a}a{color:#125dc1}nav{display:flex;gap:12px;flex-wrap:wrap}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:20px}article{background:white;padding:16px;border-radius:20px}img{width:100%;max-height:680px;object-fit:contain}h2{margin-top:48px}small{display:block;margin:12px 0}summary{cursor:pointer}details img{max-height:500px}</style><h1>Routine · local screenshot review</h1>', f'<p>{len(cards)} rendered cards · {len(groups)} device/locale groups · {len(missing)} missing inputs. Native captures and artwork are linked separately. No upload has occurred.</p><nav>']
for device in sorted({c['device'] for c in cards}):
    parts.append(f'<a href="#{html.escape(device)}">{html.escape(device)}</a>')
parts.append('</nav>')
last = None
for (device, locale), entries in sorted(groups.items()):
    if device != last:
        parts.append(f'<h2 id="{html.escape(device)}">{html.escape(device)}</h2>'); last = device
    parts.append(f'<h3 lang="{html.escape(locale)}">{html.escape(locale)}</h3><div class="cards">')
    for card in sorted(entries, key=lambda c: ['home','settings','announcement'].index(c['screen'])):
        parts.append(f'<article><h4>{html.escape(card["screen"])}</h4><a href="{link(card["output"])}"><img loading="lazy" src="{link(card["output"])}" alt="{html.escape(locale+" "+card["screen"])} artwork"></a><small>{card["width"]} × {card["height"]} pixels · <a href="{link(card["source"])}">native PNG</a> · <a href="{link(card["output"])}">rendered PNG</a></small><details><summary>Compare native capture</summary><img loading="lazy" src="{link(card["source"])}" alt="Native app screenshot"></details></article>')
    parts.append('</div>')
if missing:
    parts.append('<h2>Missing inputs</h2><pre>'+html.escape(json.dumps(missing,ensure_ascii=False,indent=2))+'</pre>')
(args.output/'index.html').write_text('\n'.join(parts))
(args.output/'coverage.json').write_text(json.dumps({'manifests':[str(p) for p in args.manifests],'cards':len(cards),'groups':[{'device':d,'locale':l,'cards':len(v)} for (d,l),v in sorted(groups.items())],'missing':missing},indent=2))
(args.output/'README.md').write_text(f'# Routine screenshot review\n\nOpen [index.html](index.html) for native/artwork comparisons. This local package contains {len(cards)} rendered cards across {len(groups)} device/locale groups; {len(missing)} inputs are missing.\n\nEvery card embeds an actual native app screenshot. Headers come from matching app localizations, and all six synthetic habit names/descriptions were translated before capture. Source PNG/pixel hashes, locale, dimensions, copy and renderer hashes are recorded in each renderer manifest; coverage.json links those manifests. Chinese phone/tablet captures use iOS 27 because the iOS 26 runtime displayed missing Chinese glyphs. Duo closed/open retain their native dimensions. Mac captures are listed separately when available.\n\nThese are review artifacts, not an App Store submission. Check each locale/device before selecting release assets. No App Store upload or publishing was performed.\n')
print(f'Gallery: {args.output}/index.html; {len(cards)} cards; {len(missing)} missing')
