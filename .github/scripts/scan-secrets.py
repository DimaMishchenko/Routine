#!/usr/bin/env python3
import argparse
import re
import subprocess
import sys

parser = argparse.ArgumentParser(description="Redacted high-confidence credential scan; no network requests")
parser.add_argument("--history", action="store_true", help="scan every locally stored Git blob, including unreachable objects")
args = parser.parse_args()
patterns = {
    "private key": rb"-----BEGIN (?:[A-Z ]+ )?PRIVATE KEY-----",
    "AWS access key": rb"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b",
    "GitHub token": rb"\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b",
    "Slack token": rb"\bxox[baprs]-[A-Za-z0-9-]{20,}",
    "Stripe secret key": rb"\bsk_(?:live|test)_[A-Za-z0-9]{20,}",
}
found = 0
checked = 0

def inspect(label, data):
    global found, checked
    checked += 1
    for name, pattern in patterns.items():
        if re.search(pattern, data):
            print(f"{label}: {name} detected (value redacted)")
            found += 1

if args.history:
    objects = subprocess.check_output([
        "git", "cat-file", "--batch-all-objects", "--batch-check=%(objectname) %(objecttype)"
    ]).decode().splitlines()
    process = subprocess.Popen(["git", "cat-file", "--batch"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in objects:
            oid, kind = entry.split()
            if kind != "blob":
                continue
            process.stdin.write((oid + "\n").encode())
            process.stdin.flush()
            header = process.stdout.readline().split()
            data = process.stdout.read(int(header[2]))
            process.stdout.read(1)
            inspect(oid, data)
    finally:
        process.stdin.close()
        process.wait()
else:
    from pathlib import Path
    paths = subprocess.check_output(["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"]).split(b"\0")
    for raw in set(paths):
        if not raw:
            continue
        path = Path(raw.decode())
        if path.is_file() and not path.is_symlink():
            inspect(str(path), path.read_bytes())
print(f"Scanned {checked} files/blobs; {found} high-confidence credential findings.")
sys.exit(1 if found else 0)
