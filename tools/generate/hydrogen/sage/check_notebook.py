#!/usr/bin/env python3

import json
from pathlib import Path


repo_root = Path(__file__).resolve().parents[4]
notebook_path = repo_root / "hydrogen.ipynb"

notebook = json.loads(
    notebook_path.read_text(
        encoding="utf-8",
    )
)

namespace = {
    "__name__": "__main__",
}

for index, cell in enumerate(notebook["cells"]):
    if cell["cell_type"] != "code":
        continue

    source = "".join(cell["source"])

    exec(
        compile(
            source,
            f"{notebook_path.name}:cell-{index}",
            "exec",
        ),
        namespace,
        namespace,
    )

print(
    "PASS: hydrogen.ipynb code cells "
    "execute under Sage"
)
