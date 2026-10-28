# Local screenshot artwork

The renderer frames real native app captures with localized headings from the app's own `Localizable.strings`. AppKit and Core Text provide native shaping, wrapping, fallback fonts and missing-glyph validation. No UI is reconstructed and no AI-generated imagery is used.

From the repository root:

```sh
mkdir -p .artifacts/modernization/store-package/.tool
swiftc -module-cache-path /tmp/routine-store-renderer-module-cache \
  Tools/store-screenshots.swift \
  -o .artifacts/modernization/store-package/.tool/store-screenshots
.artifacts/modernization/store-package/.tool/store-screenshots
```

For a focused review, pass `--devices iphone,ipad --locales en,hi,bn,ja,zh-Hans`. A different output directory can be selected with `--output`; keep generated artwork under `.artifacts/modernization/store-package`. The renderer preserves each source image's exact pixel dimensions, including landscape Mac captures. Exports are opaque RGB PNGs. Native captures are aspect fitted into a rounded pale-blue frame beneath an approximately 18% heading area. Long headings shrink to fit within measured bounds; inability to fit or missing glyphs fails visibly.

`inputs.json` specifies device directories and per-locale overrides. Only exact `{locale}-{home,settings,announcement}.png` names are considered, so unrelated QA and diagnostic frames are excluded. Chinese phone inputs come from the independently verified iOS 27 capture folder; unreadable iOS 26 Chinese captures stay quarantined. Add the independently validated Chinese tablet directory as its own `zh-Hans` override when available. The two Duo display states are separate devices. Open-state inputs use the `-unfolded` suffix, while closed-state inputs use the plain native filename. Their exact native landscape or portrait dimensions are preserved. Additional display states can use a device `suffix` or a separate native capture directory. A device can instead supply explicit `inputs` by locale and screen. `mac-inputs.json` supplies the separately captured twelve-locale native Mac set:

```sh
.artifacts/modernization/store-package/.tool/store-screenshots \
  --config Screenshots/mac-inputs.json \
  --output .artifacts/modernization/store-package/mac-review
```

Only configure captures that have been visually checked in the native app. Available `.ax.json` or `-ax.json` accessibility sidecars are checked for QA-marked user content; affected images are rejected. This gate supplements native visual review. Missing images or translations are recorded in `manifest.json`, without substituting English, another device or another screen. Missing inputs also remove the corresponding previously generated card to prevent stale artwork from remaining in that slot.

Each manifest entry records device, locale, screen, pixel dimensions, source/output PNG SHA-256, canonical decoded RGBA pixel SHA-256, localized copy keys/text, localization source hash, fitted font sizes and renderer source hash. The manifest describes the selected run; filtered review runs should use a separate output directory. Do not treat a partial manifest as a complete release package. There is no upload or App Store Connect integration.

The three artwork headers use these existing app keys:

| Native screen | Title | Subtitle |
| --- | --- | --- |
| home | `tutorial.features.maintain.title` | `tutorial.features.maintain.message` |
| settings | `freeAnnouncement.title` | `freeAnnouncement.features` |
| announcement | `settings.section.authors` | `settings.section.authorsFooter` |

## Localized synthetic habits

`sample-data.json` translates the six approved screenshot habits and their descriptions in all twelve app locales. Generate locale-specific SQLite copies with:

```sh
python3 Tools/localize-screenshot-fixture.py
```

The generator opens `.artifacts/modernization/fixtures/routine-synthetic-qa.sqlite` read only and immutable, verifies the exact six approved names/descriptions, creates each destination through SQLite backup, updates only `ZNAME` and `ZDESC` by primary key, checkpoints and closes each temporary database before renaming, then reopens the final destination read only and immutable to check the complete mapping and database integrity. It verifies the source hash is unchanged and writes locale copies plus a hash manifest under `.artifacts/modernization/fixtures`.

The generator never opens an app container or writes a production database. To recapture localized home screens, a QA worker must separately terminate its explicitly owned local simulator app, copy the appropriate generated fixture into that disposable app container, then relaunch in the matching locale. Preserve the original clean source fixture. Localize synthetic user content through these fixtures rather than editing screenshot pixels.

The clean source fixture is an ignored, task-local prerequisite and is not available in a fresh checkout. Recreate six disposable synthetic habits with exactly the English names and descriptions in `sample-data.json`, then export a consistent SQLite backup from that explicitly owned QA app. Supply it with `--source`; never use a personal or production database. Existing histories and reminder rows are retained, so use only a confirmed synthetic source.

Build a local comparison gallery from one or more renderer manifests:

```sh
python3 Tools/screenshot-gallery.py .artifacts/modernization/store-package/final/manifest.json
```

The gallery links native captures and rendered cards by device and locale, and writes `coverage.json` plus a coverage README. Add the separate Mac renderer manifest to the same command once Mac captures are complete.

To recreate that prerequisite safely:

1. Launch an isolated Local QA app and create exactly the six English names and descriptions in `sample-data.json` → `en`. Use disposable test content only.
2. Quit that exact QA app. Locate only its owned simulator/local QA store; confirm its bundle/container before continuing. Do not target a production store.
3. Set `QA_SOURCE` to that stopped app's exact SQLite path, then run this backup/export from the repository root:

```sh
QA_SOURCE='/absolute/path/to/owned/QA/RoutineApp.sqlite' python3 - <<'PY'
import contextlib, json, os, pathlib, sqlite3
source = pathlib.Path(os.environ['QA_SOURCE'])
target = pathlib.Path('.artifacts/modernization/fixtures/routine-synthetic-qa.sqlite')
expected = json.loads(pathlib.Path('Screenshots/sample-data.json').read_text())['en']
assert source.is_file() and not target.exists()
target.parent.mkdir(parents=True, exist_ok=True)
with contextlib.closing(sqlite3.connect(source.as_uri() + '?mode=ro', uri=True)) as src:
    with contextlib.closing(sqlite3.connect(target)) as dst:
        src.backup(dst)
        assert dst.execute('PRAGMA wal_checkpoint(TRUNCATE)').fetchone()[0] == 0
        assert dst.execute('PRAGMA journal_mode=DELETE').fetchone()[0] == 'delete'
with contextlib.closing(sqlite3.connect(target.resolve().as_uri() + '?mode=ro&immutable=1', uri=True)) as db:
    rows = db.execute('SELECT ZNAME, ZDESC FROM ZROUTINEENTITY').fetchall()
    assert len(rows) == 6
    assert dict(rows) == {name: value['description'] for name, value in expected.items()}
    assert db.execute('PRAGMA integrity_check').fetchone() == ('ok',)
assert not pathlib.Path(str(target) + '-wal').exists() or pathlib.Path(str(target) + '-wal').stat().st_size == 0
print('Closed, checkpointed synthetic source verified:', target)
PY
```

4. Run the localization generator above. It refuses unknown names/descriptions and independently verifies every closed destination through an immutable connection. Keep the source database and its parent app's test data local; no tracked binary fixture is required.

The generator rejects a nonempty source WAL and any existing destination WAL/SHM because another connection may still own them; it does not remove those sidecars. Quit the owner or choose a fresh `--output` directory. Generated fixtures use a standalone DELETE journal, and both ordinary read-only and immutable reads verify the final six translated rows.
