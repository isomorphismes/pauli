#!/usr/bin/env python3

from html import escape
from pathlib import Path
import re
import sys

THIS_FILE = Path(__file__).resolve()
REPO_ROOT = THIS_FILE.parents[4]
sys.path.insert(0, str(THIS_FILE.parent))

from derive import (
    angular_dimensions,
    radial_rows,
    state_counts,
    verify,
)


def replace_section(text, name, replacement):
    start = f"<!-- generated:{name}:start -->"
    end = f"<!-- generated:{name}:end -->"

    if start not in text or end not in text:
        raise ValueError(f"missing generated section {name}")

    before, rest = text.split(start, 1)
    _, after = rest.split(end, 1)

    return (
        before
        + start
        + "\n"
        + replacement.rstrip()
        + "\n"
        + end
        + after
    )


def polynomial_text(coefficients):
    superscript = {1: "", 2: "²", 3: "³"}
    pieces = []

    for power, coefficient in enumerate(coefficients):
        if coefficient == 0:
            continue

        negative = coefficient < 0
        magnitude = abs(coefficient)

        if power == 0:
            core = str(magnitude)
        else:
            variable = "r" + superscript.get(
                power,
                f"^{power}",
            )
            numerator = magnitude.numerator()
            denominator = magnitude.denominator()

            if magnitude == 1:
                core = variable
            elif denominator == 1:
                core = f"{numerator}{variable}"
            elif numerator == 1:
                core = f"{variable}/{denominator}"
            else:
                core = (
                    f"{numerator}{variable}"
                    f"/{denominator}"
                )

        if not pieces:
            pieces.append(
                ("−" if negative else "")
                + core
            )
        else:
            pieces.append(
                (" − " if negative else " + ")
                + core
            )

    return "".join(pieces) or "0"


def angular_html():
    labels = ("s", "p", "d", "f")

    return "\n".join(
        f"""<tr>
<td>{degree}</td>
<td>{dimension}</td>
<td>{labels[degree]}</td>
</tr>"""
        for degree, dimension
        in angular_dimensions()
    )


def radial_html():
    return "\n".join(
        (
            f"<tr><td>{energy_family}</td>"
            f"<td>{angular_degree}</td>"
            f"<td><code>{escape(polynomial_text(coefficients))}</code></td></tr>"
        )
        for (
            energy_family,
            angular_degree,
            coefficients,
        )
        in radial_rows()
    )


def counts_html():
    counts = state_counts()

    return (
        "<strong>"
        + " + ".join(str(value) for value in counts)
        + " = "
        + str(sum(counts))
        + "</strong>"
    )


def strip_markdown(text):
    text = re.sub(r"\*([^*]+)\*", r"\1", text)
    text = re.sub(r"`([^`]+)`", r"\1", text)
    return text.strip()


def book_items_html():
    readme = (
        REPO_ROOT
        / "books"
        / "README.md"
    ).read_text(encoding="utf-8")

    section = readme.split(
        "## Main references",
        1,
    )[1].split(
        "## Books not personally read",
        1,
    )[0]

    pattern = re.compile(
        r"^- \[(.+?)\]\((.+?)\)(.*)$"
    )

    items = []

    for line in section.splitlines():
        match = pattern.match(line.strip())

        if not match:
            continue

        title = strip_markdown(match.group(1))
        note = strip_markdown(
            match.group(3).lstrip(" —-")
        )

        note_html = (
            f"<br><span class=\"small\">"
            f"{escape(note, quote=False)}</span>"
            if note
            else ""
        )

        items.append(
            "<li>"
            f"<strong>{escape(title, quote=False)}</strong>"
            f"{note_html}"
            "</li>"
        )

    return "\n".join(items)


def update_file(path, sections):
    text = path.read_text(encoding="utf-8")

    for name, replacement in sections:
        text = replace_section(
            text,
            name,
            replacement,
        )

    path.write_text(text, encoding="utf-8")


def main():
    verify()

    update_file(
        REPO_ROOT / "hydrogen.html",
        [
            ("angular", angular_html()),
            ("radial", radial_html()),
            ("counts", counts_html()),
        ],
    )

    update_file(
        REPO_ROOT / "books.html",
        [
            ("books", book_items_html()),
        ],
    )

    print(
        "PASS: regenerated hydrogen.html "
        "and books.html from Sage results"
    )


if __name__ == "__main__":
    main()
