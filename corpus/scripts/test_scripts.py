"""Golden tests for manifest.py and index.py. Run: python3 -m unittest corpus/scripts/test_scripts.py"""

import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import index  # noqa: E402
import manifest  # noqa: E402

FIXTURE = os.path.join(os.path.dirname(__file__), "testdata", "run")


class ManifestTest(unittest.TestCase):
    def test_build(self):
        with open(os.path.join(FIXTURE, ".log.tsv")) as f:
            m = manifest.build("go", "golang:1.27.3", FIXTURE, f.readlines())
        self.assertEqual(
            m,
            {
                "emitter": "go",
                "image": "golang:1.27.3",
                "tools": {"go": "go version go1.27.3 linux/arm64"},
                "steps": [{"cwd": "/work/go", "command": "go test -coverprofile=a.out ./..."}],
                "notes": ["set mode records hit or not hit only"],
                "reports": [
                    {
                        "path": "a.out",
                        "format": "go-coverprofile",
                        "source": "/work/go/a.out",
                        "bytes": 27,
                        "sha256": "bfd100be3d953c2e9847659f03af045cc93e6f992c3872d7a7ef72f60e9a4021",
                    }
                ],
            },
        )

    def test_unknown_kind_fails(self):
        with self.assertRaises(ValueError):
            manifest.build("x", "img", FIXTURE, ["bogus\tline\n"])


class IndexTest(unittest.TestCase):
    def test_render(self):
        m = {
            "emitter": "go",
            "image": "golang:1.27.3",
            "tools": {"go": "go1.27.3"},
            "reports": [{"path": "a.out", "format": "go-coverprofile", "bytes": 1200}],
        }
        out = index.render([m])
        self.assertIn("| [go](go/manifest.json) | `golang:1.27.3` | go: `go1.27.3` |", out)
        self.assertIn("| go-coverprofile | go | [a.out](go/a.out) | 1,200 |", out)


if __name__ == "__main__":
    unittest.main()
