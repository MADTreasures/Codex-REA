#!/usr/bin/env python3
"""Check observed provider, binary digest, function recovery and decompilation."""
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
digest = hashlib.sha256((root / "fixture.elf").read_bytes()).hexdigest()
assert digest == (root / "fixture.sha256").read_text().split()[0], "ELF was modified"
functions = json.loads((root / "rea-functions.json").read_text())
function = json.loads((root / "rea-function.json").read_text())
decompilation = json.loads((root / "rea-decompilation.json").read_text())
for evidence in [functions, function, decompilation]:
    assert evidence["provider"]["id"] == "ghidra", evidence["provider"]
    assert evidence["provider"]["version"] == "12.1.4", evidence["provider"]
    assert evidence["subject"]["digest"]["sha256"] == digest
assert {item["value"] for item in functions["normalized_result"]} >= {"re_add", "re_score"}
recovered = function["normalized_result"]
assert recovered["procedure"]["name"] == "re_add"
assert recovered["assembly"], "No instructions returned"
assert "return right + left;" in recovered["pseudocode"], "Actual addition was not recovered"
assert "return right + left;" in json.dumps(decompilation["normalized_result"])
print("REA_GHIDRA_SMOKE_OK: matching ELF digest, functions, instructions and decompilation")
