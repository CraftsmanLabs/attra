"""Turn an emitter's run log into reports/<emitter>/manifest.json.

Usage: python3 scripts/manifest.py EMITTER IMAGE [REPORTS_DIR]

The run log (.log.tsv) is written by emitters/lib.sh inside the container.
Each line is tab-separated: tool|step|report|note, then fields.
"""

import hashlib
import json
import os
import sys


def build(emitter, image, out_dir, log_lines):
    manifest = {"emitter": emitter, "image": image, "tools": {}, "steps": [], "notes": [], "reports": []}
    for raw in log_lines:
        line = raw.rstrip("\n")
        if not line:
            continue
        kind, *fields = line.split("\t")
        if kind == "tool":
            manifest["tools"][fields[0]] = fields[1] if len(fields) > 1 else ""
        elif kind == "step":
            manifest["steps"].append({"cwd": fields[0], "command": fields[1]})
        elif kind == "note":
            manifest["notes"].append(fields[0])
        elif kind == "report":
            path, fmt, source = fields
            manifest["reports"].append({"path": path, "format": fmt, "source": source, **describe(os.path.join(out_dir, path))})
        else:
            raise ValueError(f"unknown log line kind: {kind!r}")
    manifest["reports"].sort(key=lambda r: r["path"])
    return manifest


def describe(path):
    """Size and sha256 of a report file, or of every file under a report directory."""
    if os.path.isdir(path):
        files = sorted(
            os.path.relpath(os.path.join(d, f), path) for d, _, fs in os.walk(path) for f in fs
        )
        return {"files": {f: describe(os.path.join(path, f)) for f in files}}
    with open(path, "rb") as f:
        data = f.read()
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def main(argv):
    emitter, image = argv[1], argv[2]
    out_dir = argv[3] if len(argv) > 3 else os.path.join(os.path.dirname(__file__), "..", "reports", emitter)
    log_path = os.path.join(out_dir, ".log.tsv")
    with open(log_path) as f:
        manifest = build(emitter, image, out_dir, f.readlines())
    with open(os.path.join(out_dir, "manifest.json"), "w") as f:
        json.dump(manifest, f, indent=2)
        f.write("\n")
    os.remove(log_path)


if __name__ == "__main__":
    main(sys.argv)
