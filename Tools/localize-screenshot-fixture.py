import argparse
from contextlib import closing
import hashlib
import json
import os
from pathlib import Path
import sqlite3
import tempfile

parser = argparse.ArgumentParser(description="Create localized copies of the six-routine synthetic screenshot fixture.")
parser.add_argument("--source", type=Path, default=Path(".artifacts/modernization/fixtures/routine-synthetic-qa.sqlite"))
parser.add_argument("--translations", type=Path, default=Path("Screenshots/sample-data.json"))
parser.add_argument("--output", type=Path, default=Path(".artifacts/modernization/fixtures"))
parser.add_argument("--locales", help="Comma-separated locale identifiers; defaults to every translated locale")
args = parser.parse_args()
source = args.source.resolve(strict=True)
source_wal = Path(str(source) + "-wal")
if source_wal.exists() and source_wal.stat().st_size:
    raise SystemExit("The source must be closed and fully checkpointed; nonempty WAL found")
translations_data = args.translations.read_bytes()
translations = json.loads(translations_data)
locales = args.locales.split(",") if args.locales else sorted(translations)
source_hash = hashlib.sha256(source.read_bytes()).hexdigest()
args.output.mkdir(parents=True, exist_ok=True)
outputs = []
with closing(sqlite3.connect(source.as_uri() + "?mode=ro&immutable=1", uri=True)) as original:
    rows = original.execute("SELECT Z_PK, ZNAME, ZDESC FROM ZROUTINEENTITY").fetchall()
    expected = translations["en"]
    if len(rows) != 6 or {name for _, name, _ in rows} != set(expected):
        raise SystemExit("The source must contain exactly the six approved synthetic routines")
    if any(description != expected[name]["description"] for _, name, description in rows):
        raise SystemExit("The source descriptions do not match the approved synthetic fixture")
    for locale in locales:
        values = translations.get(locale)
        if not values or set(values) != set(expected):
            raise SystemExit(f"Missing or incomplete translations for {locale}")
        for pair in values.values():
            if set(pair) != {"name", "description"} or not all(isinstance(value, str) and value.strip() for value in pair.values()):
                raise SystemExit(f"Invalid localized name/description for {locale}")
        target = (args.output / f"{locale}.sqlite").resolve()
        if target == source:
            raise SystemExit("The destination must not replace the immutable source")
        if any(Path(str(target) + suffix).exists() for suffix in ["-wal", "-shm"]):
            raise SystemExit(f"Destination has SQLite sidecars and may be active: {target}")
        descriptor, temporary_path = tempfile.mkstemp(prefix=f".{locale}-", suffix=".sqlite", dir=args.output)
        os.close(descriptor)
        temporary = Path(temporary_path)
        try:
            with closing(sqlite3.connect(temporary)) as localized:
                original.backup(localized)
                localized.executemany("UPDATE ZROUTINEENTITY SET ZNAME = ?, ZDESC = ? WHERE Z_PK = ?", [
                    (values[name]["name"], values[name]["description"], identifier) for identifier, name, _ in rows
                ])
                localized.commit()
                actual = localized.execute("SELECT Z_PK, ZNAME, ZDESC FROM ZROUTINEENTITY ORDER BY Z_PK").fetchall()
                wanted = sorted((identifier, values[name]["name"], values[name]["description"]) for identifier, name, _ in rows)
                if actual != wanted or localized.execute("PRAGMA integrity_check").fetchone() != ("ok",):
                    raise SystemExit(f"Localized fixture validation failed for {locale}")
                checkpoint = localized.execute("PRAGMA wal_checkpoint(TRUNCATE)").fetchone()
                if checkpoint[0] != 0:
                    raise SystemExit(f"Unable to checkpoint the localized fixture for {locale}")
                if localized.execute("PRAGMA journal_mode=DELETE").fetchone()[0] != "delete":
                    raise SystemExit(f"Unable to make the localized fixture standalone for {locale}")
            os.replace(temporary, target)
            with closing(sqlite3.connect(target.as_uri() + "?mode=ro&immutable=1", uri=True)) as reopened:
                saved = reopened.execute("SELECT Z_PK, ZNAME, ZDESC FROM ZROUTINEENTITY ORDER BY Z_PK").fetchall()
                if saved != wanted or reopened.execute("PRAGMA integrity_check").fetchone() != ("ok",):
                    raise SystemExit(f"Immutable destination verification failed for {locale}")
            with closing(sqlite3.connect(target.as_uri() + "?mode=ro", uri=True)) as ordinary:
                saved = ordinary.execute("SELECT Z_PK, ZNAME, ZDESC FROM ZROUTINEENTITY ORDER BY Z_PK").fetchall()
                if saved != wanted or ordinary.execute("PRAGMA integrity_check").fetchone() != ("ok",):
                    raise SystemExit(f"Ordinary destination verification failed for {locale}")
            outputs.append({"locale": locale, "path": str(target), "sha256": hashlib.sha256(target.read_bytes()).hexdigest(), "routines": 6})
            print(f"Ready {locale}: {target}", flush=True)
        finally:
            temporary.unlink(missing_ok=True)
            Path(str(temporary) + "-wal").unlink(missing_ok=True)
            Path(str(temporary) + "-shm").unlink(missing_ok=True)
if hashlib.sha256(source.read_bytes()).hexdigest() != source_hash:
    raise SystemExit("The source fixture changed during generation")
manifest = {"source": str(source), "sourceSHA256": source_hash, "translationsSHA256": hashlib.sha256(translations_data).hexdigest(), "outputs": outputs}
(args.output / "localization-manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
