from __future__ import annotations

import csv
import html
import json
import re
import sys
import zipfile
from pathlib import Path
from xml.sax.saxutils import escape


DEFAULT_ROOT = Path("outputs") / "sis_course_outlines"
DEFAULT_OUT = Path("outputs") / "sis_course_outlines_export.xlsx"


HEADERS = [
    "letter",
    "subject",
    "course_code",
    "course_number",
    "course_title",
    "status",
    "units",
    "grading_basis",
    "component",
    "campus",
    "school",
    "academic_org",
    "detail_description",
    "language_of_instruction",
    "description_english",
    "description_chinese",
    "prerequisites",
    "co_requisites",
    "learning_outcomes",
    "course_syllabus",
    "assessment_scheme",
    "grade_type",
    "course_components",
    "terms_status",
    "offered_terms",
    "terms_text",
    "source_folder",
]


def read_json(path: str | Path) -> dict:
    if not path:
        return {}
    p = Path(path)
    if not p.exists():
        return {}
    try:
        return json.loads(p.read_text(encoding="utf-8-sig"))
    except Exception:
        return {}


def read_text(path: str | Path) -> str:
    if not path:
        return ""
    p = Path(path)
    if not p.exists():
        return ""
    try:
        return p.read_text(encoding="utf-8-sig", errors="ignore")
    except Exception:
        return ""


def stringify_items(value) -> str:
    if not value:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, list):
        lines = []
        for row in value:
            if isinstance(row, list):
                lines.append(" | ".join(str(x) for x in row if str(x).strip()))
            else:
                lines.append(str(row))
        return "\n".join(line for line in lines if line.strip())
    return json.dumps(value, ensure_ascii=False)


def extract_offered_terms(text: str) -> str:
    if not text:
        return ""

    candidates: list[str] = []
    # The SIS terms page usually has a "提供学期 / Offered Terms" block, but the
    # same term can also appear in section headings. Deduplicate while preserving
    # page order.
    patterns = [
        r"\b20\d{2}-\d{2}\s+Term\s+\d+\b",
        r"\b20\d{2}-\d{2}\s+(?:Summer|Spring|Fall|Autumn|Winter)\b",
    ]
    for pattern in patterns:
        candidates.extend(re.findall(pattern, text, flags=re.IGNORECASE))

    seen = set()
    terms = []
    for term in candidates:
        normalized = re.sub(r"\s+", " ", term).strip()
        key = normalized.lower()
        if key not in seen:
            seen.add(key)
            terms.append(normalized)
    return "\n".join(terms)


def first_file(folder: Path, pattern: str) -> Path | None:
    files = sorted(folder.glob(pattern))
    return files[0] if files else None


def rows_from_manifest(root: Path) -> list[dict]:
    rows: list[dict] = []
    manifest_dir = root / "_manifests"
    for manifest in sorted(manifest_dir.glob("manifest_letter_*.csv")):
        try:
            with manifest.open("r", encoding="utf-8-sig", newline="") as f:
                for row in csv.DictReader(f):
                    row["_manifest"] = str(manifest)
                    rows.append(row)
        except Exception as exc:
            print(f"WARNING: cannot read manifest {manifest}: {exc}")
    return rows


def rows_from_folders(root: Path) -> list[dict]:
    rows: list[dict] = []
    for detail_path in sorted(root.glob("letter_*/courses/*/detail.json")):
        folder = detail_path.parent
        detail = read_json(detail_path)
        outline_path = first_file(folder, "*_course_outline_fields.json")
        terms_path = first_file(folder, "*_all_offered_terms_full_text.txt")
        letter = detail_path.parents[2].name.replace("letter_", "")
        folder_code, _, folder_title = folder.name.partition("_")
        rows.append(
            {
                "letter": letter,
                "subject": detail.get("subject", ""),
                "course_code": detail.get("courseCode", "") or folder_code,
                "course_number": detail.get("courseNumber", ""),
                "course_title": detail.get("courseTitle", "") or folder_title,
                "status": "saved_outline" if outline_path else "detail_only",
                "outline_json": str(outline_path or ""),
                "terms_status": "saved_terms" if terms_path else "",
                "terms_text": str(terms_path or ""),
                "detail_json": str(detail_path),
                "_manifest": "filesystem_scan",
            }
        )
    return rows


def normalize_manifest_paths(root: Path, manifest_rows: list[dict]) -> list[dict]:
    """Older manifests may contain paths from another cwd. Rebuild paths from folders when needed."""
    if not manifest_rows:
        return []
    by_code = {}
    for row in rows_from_folders(root):
        by_code[row.get("course_code", "")] = row

    normalized = []
    for row in manifest_rows:
        code = row.get("course_code", "")
        folder_row = by_code.get(code, {})
        merged = dict(row)
        for key in ("detail_json", "outline_json", "terms_text", "terms_status"):
            if not merged.get(key) or not Path(merged.get(key, "")).exists():
                if folder_row.get(key):
                    merged[key] = folder_row[key]
        normalized.append(merged)
    return normalized


def build_rows(root: Path) -> list[dict]:
    manifest_rows = normalize_manifest_paths(root, rows_from_manifest(root))
    source_rows = manifest_rows or rows_from_folders(root)
    out_rows = []

    for m in source_rows:
        detail = read_json(m.get("detail_json", ""))
        outline = read_json(m.get("outline_json", ""))
        terms_text = read_text(m.get("terms_text", ""))
        offered_terms = extract_offered_terms(terms_text)
        folder = str(Path(m.get("detail_json", "")).parent) if m.get("detail_json") else ""

        out_rows.append(
            {
                "letter": m.get("letter", ""),
                "subject": m.get("subject", ""),
                "course_code": m.get("course_code", "") or detail.get("courseCode", ""),
                "course_number": m.get("course_number", "") or detail.get("courseNumber", ""),
                "course_title": m.get("course_title", "") or detail.get("courseTitle", ""),
                "status": m.get("status", ""),
                "units": detail.get("units", ""),
                "grading_basis": detail.get("gradingBasis", ""),
                "component": detail.get("component", ""),
                "campus": detail.get("campus", ""),
                "school": detail.get("school", ""),
                "academic_org": detail.get("academicOrg", ""),
                "detail_description": detail.get("description", ""),
                "language_of_instruction": outline.get("languageOfInstruction", ""),
                "description_english": outline.get("descriptionEnglish", ""),
                "description_chinese": outline.get("descriptionChinese", ""),
                "prerequisites": outline.get("prerequisites", ""),
                "co_requisites": outline.get("coRequisites", ""),
                "learning_outcomes": outline.get("learningOutcomes", ""),
                "course_syllabus": outline.get("courseSyllabus", ""),
                "assessment_scheme": outline.get("assessmentScheme", "")
                or stringify_items(outline.get("assessmentSchemeItems", "")),
                "grade_type": outline.get("gradeType", "") or stringify_items(outline.get("gradeTypeItems", "")),
                "course_components": outline.get("courseComponents", "")
                or stringify_items(outline.get("courseComponentItems", "")),
                "terms_status": m.get("terms_status", ""),
                "offered_terms": offered_terms,
                "terms_text": terms_text,
                "source_folder": folder,
            }
        )

    return out_rows


def col_name(index: int) -> str:
    name = ""
    while index:
        index, rem = divmod(index - 1, 26)
        name = chr(65 + rem) + name
    return name


def clean_cell(value) -> str:
    text = "" if value is None else str(value)
    # Excel XML accepts LF but not most control chars.
    text = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f]", " ", text)
    return text


def sheet_xml(rows: list[list[str]], freeze: bool = True) -> str:
    row_xml = []
    for r_idx, row in enumerate(rows, start=1):
        cells = []
        for c_idx, value in enumerate(row, start=1):
            ref = f"{col_name(c_idx)}{r_idx}"
            style = 1 if r_idx == 1 else 2
            text = escape(clean_cell(value))
            cells.append(f'<c r="{ref}" t="inlineStr" s="{style}"><is><t xml:space="preserve">{text}</t></is></c>')
        row_xml.append(f'<row r="{r_idx}">{"".join(cells)}</row>')

    cols = "".join(
        f'<col min="{i}" max="{i}" width="{width}" customWidth="1"/>'
        for i, width in enumerate(
            [10, 18, 14, 14, 36, 18, 10, 16, 18, 18, 28, 28, 50, 18, 60, 60, 38, 38, 60, 60, 42, 18, 34, 18, 60, 48],
            start=1,
        )
    )
    freeze_xml = (
        '<sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" '
        'state="frozen"/><selection pane="bottomLeft"/></sheetView></sheetViews>'
        if freeze
        else '<sheetViews><sheetView workbookViewId="0"/></sheetViews>'
    )
    dimension = f"A1:{col_name(len(rows[0]) if rows else 1)}{max(len(rows), 1)}"
    auto_filter = f'<autoFilter ref="{dimension}"/>'
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        f'<dimension ref="{dimension}"/>'
        f"{freeze_xml}"
        f"<cols>{cols}</cols>"
        f'<sheetData>{"".join(row_xml)}</sheetData>'
        f"{auto_filter}"
        "</worksheet>"
    )


def write_xlsx(path: Path, sheets: list[tuple[str, list[dict]]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    sheet_entries = []
    rels = []
    workbook_sheets = []
    content_overrides = [
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
        '<Default Extension="xml" ContentType="application/xml"/>',
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>',
    ]

    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zf:
        for idx, (name, dict_rows) in enumerate(sheets, start=1):
            safe_sheet_name = name[:31]
            matrix = [HEADERS] + [[row.get(header, "") for header in HEADERS] for row in dict_rows]
            zf.writestr(f"xl/worksheets/sheet{idx}.xml", sheet_xml(matrix))
            workbook_sheets.append(f'<sheet name="{escape(safe_sheet_name)}" sheetId="{idx}" r:id="rId{idx}"/>')
            rels.append(
                f'<Relationship Id="rId{idx}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet{idx}.xml"/>'
            )
            content_overrides.append(
                f'<Override PartName="/xl/worksheets/sheet{idx}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
            )

        rels.append(
            f'<Relationship Id="rId{len(sheets) + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        )

        zf.writestr(
            "[Content_Types].xml",
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            + "".join(content_overrides)
            + "</Types>",
        )
        zf.writestr(
            "_rels/.rels",
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
            "</Relationships>",
        )
        zf.writestr(
            "xl/workbook.xml",
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
            'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
            f'<sheets>{"".join(workbook_sheets)}</sheets>'
            "</workbook>",
        )
        zf.writestr(
            "xl/_rels/workbook.xml.rels",
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            + "".join(rels)
            + "</Relationships>",
        )
        zf.writestr(
            "xl/styles.xml",
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
            '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
            '<font><b/><color rgb="FFFFFFFF"/><sz val="11"/><name val="Calibri"/></font></fonts>'
            '<fills count="3"><fill><patternFill patternType="none"/></fill>'
            '<fill><patternFill patternType="gray125"/></fill>'
            '<fill><patternFill patternType="solid"><fgColor rgb="FF1F4E78"/><bgColor indexed="64"/></patternFill></fill></fills>'
            '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
            '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
            '<cellXfs count="3"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
            '<xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>'
            '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0" applyAlignment="1"><alignment vertical="top" wrapText="1"/></xf></cellXfs>'
            '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
            "</styleSheet>",
        )


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) >= 2 else DEFAULT_ROOT
    out = Path(sys.argv[2]) if len(sys.argv) >= 3 else DEFAULT_OUT

    if not root.exists():
        print(f"ERROR: cannot find {root.resolve()}")
        print("Run this script from the ToDesk folder, or pass the sis_course_outlines folder as the first argument.")
        return 1

    rows = build_rows(root)
    if not rows:
        print(f"ERROR: found no course rows under {root.resolve()}")
        print("Expected folders like: outputs/sis_course_outlines/letter_A/courses/ACT2111_xxx/detail.json")
        return 1

    with_outline = [r for r in rows if r.get("description_english") or r.get("learning_outcomes")]
    missing = [r for r in rows if not (r.get("description_english") or r.get("learning_outcomes"))]
    write_xlsx(out, [("All Courses", rows), ("With Outline", with_outline), ("Missing Outline", missing)])
    print(f"Saved: {out.resolve()}")
    print(f"Rows: {len(rows)} total, {len(with_outline)} with outline, {len(missing)} missing/ghost/detail-only")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
