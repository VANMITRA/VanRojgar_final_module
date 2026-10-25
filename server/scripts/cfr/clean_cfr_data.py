"""Clean the raw CFR Nashik 2026 files into small JSON files that are safe to commit.

    python -I -X utf8 clean_cfr_data.py "<CFR Nashik 2026..xlsx>" "<CFR_Nashik_2026_MRSAC_Resources.docx>" <out-dir>

Needs: pip install openpyxl python-docx

What is KEPT (village-level facts only): village, taluka, claim number, rights letters, forest compartment,
claimed and approved area, the committee's decision, whether a CFR management committee is recorded.
What is DROPPED and never written anywhere: the claimant column, every committee member's name and phone,
the bank name, branch, account number and IFSC code.

The MRSAC document is read for the village resource facts, with the figures exactly as printed.
"""
import json
import re
import sys
from collections import Counter
from pathlib import Path

import docx
import openpyxl
from docx.table import Table
from docx.text.paragraph import Paragraph

SHEET_TALUKA = {
    "Nashik": "Nashik", "Dindori": "Dindori", "Peth": "Peth", "IGT": "Igatpuri", "TBK": "Trimbakeshwar",
    "Surgana": "Surgana", "Sinnar": "Sinnar", "Chandwad": "Chandwad", "Kalvan": "Kalwan", "Deola": "Deola",
    "Malegaon": "Malegaon", "Baglan": "Baglan", "Nandgaon": "Nandgaon", "Yeola": "Yeola",
}
DECISIONS = {"पात्र": "approved", "अपात्र": "rejected", "प्रलंबित": "pending"}
INVISIBLE = dict.fromkeys(map(ord, "​‌‍﻿"), None)
RIGHT_LETTERS = "कखगघङचछजझञटठड"
SOURCE = "CFR Nashik 2026 register (district committee list); MRSAC geoportal village data, October 2026"


def clean(text):
    return re.sub(r"\s+", " ", str(text).translate(INVISIBLE)).strip()


def norm_name(text):
    """Key for matching a village across the two files (spelling variants of the same name collapse)."""
    t = clean(text).translate(INVISIBLE)
    t = t.replace("ँ", "ं").replace("ळ", "ल").replace("ऱ", "र").replace("‍", "")
    t = re.sub(r"ां?ंव$", "ाव", t)          # गांव / गाव
    t = re.sub(r"[\s\-\(\)\.]", "", t)
    return t


MAX_AREA_HA = 5000.0   # a community forest claim above this is a shifted column (for example an account number), not an area


def num(v):
    if isinstance(v, bool) or v is None:
        return None
    try:
        n = float(v) if isinstance(v, (int, float)) else float(str(v).replace(",", "").strip())
    except ValueError:
        return None
    return n if 0 <= n <= MAX_AREA_HA else None


def looks_like_rights(v):
    if not isinstance(v, str):
        return False
    return "3(1)" in v or any(ch in v for ch in RIGHT_LETTERS)


def clean_claims(xlsx_path):
    wb = openpyxl.load_workbook(xlsx_path, data_only=True)
    claims, stats = [], Counter()
    for sheet, taluka in SHEET_TALUKA.items():
        for r in list(wb[sheet].iter_rows(values_only=True))[2:]:
            r = list(r) + [None] * 26
            village = clean(r[3]) if r[3] is not None else ""
            if not village or re.fullmatch(r"[\d.]+", village) or r[2] is None:
                continue
            case = r[1]
            case_no = str(int(case)) if isinstance(case, (int, float)) and float(case).is_integer() else clean(case or "")
            decision = next((DECISIONS[clean(c)] for c in r[8:13] if isinstance(c, str) and clean(c) in DECISIONS), None)
            nums = [num(c) for c in r[7:11]]
            claimed, approved = nums[0], nums[3]
            if approved is None:
                approved = next((n for n in reversed(nums[1:3]) if n is not None), None)
            rights = clean(r[5]) if looks_like_rights(r[5]) else None
            stats["rows"] += 1
            stats["area_implausible"] += any(isinstance(c, (int, float)) and not isinstance(c, bool) and c > MAX_AREA_HA for c in r[7:11])
            stats["rights_missing"] += rights is None
            stats["decision_missing"] += decision is None
            claims.append({
                "caseNo": case_no or None,
                "village": village,
                "taluka": taluka,
                "rightsRaw": rights,
                "compartment": clean(r[6]) if r[6] is not None else None,
                "areaClaimedHa": claimed,
                "areaApprovedHa": approved,
                "decision": decision,
                "cfrCommittee": isinstance(r[12], str) and clean(r[12]).lower().startswith("yes"),
            })
    return claims, stats


def redact(text):
    """The MRSAC tourism layer lists homestay owners by name; keep that a homestay exists, never who owns it."""
    return re.sub(r"(MTDC homestay):\s*[^;·]+?(?=\s*(?:;|·|$))", r" listed", text)


def find_num(pattern, text, group=1):
    m = re.search(pattern, text or "", re.I)
    return float(m.group(group).replace(",", "")) if m else None


def profile_from_rows(rows):
    general, forest = rows.get("General", ""), rows.get("Forest", "")
    soil, water = rows.get("Soil", ""), rows.get("Water resources", "")
    wells, works = rows.get("Wells", ""), rows.get("Water conservation works", "")
    soil_type = None
    m = re.search(r"type:\s*(.+?)(?:\s*·|$)", soil)
    if m:
        soil_type = m.group(1).strip()
    area = find_num(r"Village area:\s*([\d,.]+)\s*ha", general)
    forest_ha = find_num(r"^([\d,.]+)\s*ha inside", forest) or 0
    highlights = []
    if forest_ha:
        highlights.append(forest.split(".")[0] if len(forest) < 140 else re.sub(r"\.\s*Forest administration.*", "", forest)[:140])
    if wells:
        highlights.append("Wells: " + wells.split(":")[0])
    return {
        "villageAreaHa": area,
        "forestHa": forest_ha,
        "waterBodiesCount": int(find_num(r"(\d+)\s+water bodies", water) or 0),
        "wellsTotal": int(find_num(r"(\d+)\s+in total", wells) or 0),
        "waterConservationWorks": int(find_num(r"(\d+)\s+structures", works) or 0),
        "soilType": soil_type,
        "highlights": highlights,
        "rawDetails": rows,
    }


def clean_profiles(docx_path):
    d = docx.Document(docx_path)
    seq = []
    for ch in d.element.body.iterchildren():
        tag = ch.tag.split("}")[1]
        if tag == "p":
            seq.append(("p", Paragraph(ch, d)))
        elif tag == "tbl":
            seq.append(("t", Table(ch, d)))
    heading = re.compile(r"^(.+?)\s*/\s*(.+?)\s*\(census code\s*(\d+)\)\s*$")
    taluka_head = re.compile(r"^(\w[\w ]*?) taluka \((\d+) villages?\)")
    taluka, profiles, unmatched = None, [], {}
    i = 0
    in_unmatched = False
    while i < len(seq):
        kind, obj = seq[i]
        if kind == "p":
            text = clean(obj.text)
            th = taluka_head.match(text)
            if th:
                taluka = th.group(1).strip()
            if text.startswith("CFR villages not found"):
                in_unmatched = True
            elif in_unmatched and ":" in text and not text.startswith("These CFR"):
                name, rest = text.split(":", 1)
                unmatched[name.strip()] = [clean(x) for x in rest.split(",") if clean(x)]
            h = heading.match(text)
            if h and taluka:
                village_mr, village_en, code = h.group(1).strip(), h.group(2).strip(), h.group(3)
                entry_names, gram_panchayat = [], None
                j = i + 1
                if j < len(seq) and seq[j][0] == "p" and clean(seq[j][1].text).startswith("CFR entry:"):
                    m = re.match(r"CFR entry:\s*(.*?)(?:\s*·\s*Gram panchayat:\s*(.*))?$", clean(seq[j][1].text))
                    entry_names = [clean(x) for x in re.split(r"[;,]", m.group(1)) if clean(x)]
                    gram_panchayat = clean(m.group(2)) if m.group(2) else None
                    j += 1
                rows = {}
                if j < len(seq) and seq[j][0] == "t":
                    for row in seq[j][1].rows:
                        rows[clean(row.cells[0].text)] = redact(clean(row.cells[1].text))
                profiles.append({
                    "censusCode": code, "villageMr": village_mr, "villageEn": village_en, "taluka": taluka,
                    "cfrEntryNames": entry_names, "gramPanchayat": gram_panchayat, **profile_from_rows(rows),
                })
                i = j
        i += 1
    return profiles, unmatched


def main(xlsx, docx_path, out):
    out = Path(out)
    out.mkdir(parents=True, exist_ok=True)
    claims, cstats = clean_claims(xlsx)
    profiles, unmatched = clean_profiles(docx_path)

    # Link each claim's village to a MRSAC profile (census code) by taluka + normalised name.
    by_key = {}
    for p in profiles:
        for name in p["cfrEntryNames"] or [p["villageMr"]]:
            by_key.setdefault((p["taluka"], norm_name(name)), p)
    linked = 0
    for c in claims:
        p = by_key.get((c["taluka"], norm_name(c["village"])))
        c["censusCode"] = p["censusCode"] if p else None
        linked += p is not None

    def dump(name, data):
        (out / name).write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

    dump("cfr_claims.json", {"source": SOURCE, "claims": claims})
    dump("village_profiles.json", {"source": SOURCE, "profiles": profiles})
    dump("unmatched_villages.json", {"source": SOURCE, "byTaluka": unmatched})

    villages = {(c["taluka"], norm_name(c["village"])) for c in claims}
    print(f"claim rows: {len(claims)}  distinct villages: {len(villages)}")
    print(f"rows with an implausible area value set to empty: {cstats['area_implausible']}")
    print(f"rows with rights missing: {cstats['rights_missing']}  decision missing: {cstats['decision_missing']}")
    print(f"claims linked to a MRSAC census code: {linked} of {len(claims)}")
    print(f"MRSAC village profiles: {len(profiles)}  unmatched CFR names listed: {sum(len(v) for v in unmatched.values())}")
    print("decisions:", dict(Counter(c['decision'] for c in claims)))
    blob = (out / "cfr_claims.json").read_text(encoding="utf-8") + (out / "village_profiles.json").read_text(encoding="utf-8")
    assert not re.search(r"\d{9,}", blob), "a long number (phone or account) is present"
    assert not any(w in blob.lower() for w in ("mobile", "ifsc", "bank of")), "personal column leaked"
    assert not re.search(r"homestay:", blob), "homestay owner name present"


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(*sys.argv[1:])
