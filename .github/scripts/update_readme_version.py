"""Update Atomic's README dependency example after a stable release."""

import re
import sys
from pathlib import Path


VERSION = r"(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"
DEPENDENCY = re.compile(
    r'(\.package\(url: "https://github\.com/bencmorrison/Atomic\.git", from: ")'
    r'(?P<version>[^"\n]+)("\))'
)


def update_readme(text, tag):
    version = tag.removeprefix("v")
    released = re.fullmatch(VERSION, version)
    if released is None:
        raise ValueError("Expected a stable release tag such as 1.2.3 or v1.2.3")

    matches = list(DEPENDENCY.finditer(text))
    if len(matches) != 1:
        raise ValueError("Expected exactly one Atomic dependency example in README.md")

    match = matches[0]
    current = match.group("version")
    if current != "<RELEASE_NUMBER>":
        existing = re.fullmatch(VERSION, current)
        if existing is None:
            raise ValueError("The README dependency has an unexpected version")
        if tuple(map(int, released.groups())) <= tuple(map(int, existing.groups())):
            return text

    start, end = match.span("version")
    return text[:start] + version + text[end:]


if __name__ == "__main__":
    readme = Path("README.md")
    original = readme.read_text()
    updated = update_readme(original, sys.argv[1])
    if updated != original:
        readme.write_text(updated)
        print("Updated the README dependency version.")
    else:
        print("Skipped an equal or older release version.")
