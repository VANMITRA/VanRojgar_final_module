"""
OpenStreetMap (Overpass) elements -> a resource dataset that `loader.validate_dataset` accepts.

PURE: no network, no database. `scripts/build_osm_resources.py` fetches and calls `to_dataset`.
Every feature is labelled low confidence and "to verify": OpenStreetMap in rural districts is
patchy and
nobody has surveyed these places for this app. The data is (c) OpenStreetMap contributors, ODbL.
"""

import re
from datetime import UTC, datetime
from typing import Any

SOURCE = "OpenStreetMap contributors (ODbL), via the Overpass API"
DATASET = "osm_nashik_2026"
_DEVANAGARI = re.compile(r"[ऀ-ॿ]")
_WILDLIFE = re.compile(r"wildlife|sanctuary|national park|tiger|वन्यजीव|अभयारण्य", re.I)


def _names(tags: dict[str, str], fallback: str) -> tuple[str, str]:
    name = tags.get("name", "").strip()
    name_mr = tags.get("name:mr", "").strip() or (name if _DEVANAGARI.search(name) else "")
    name_en = tags.get("name:en", "").strip() or (
        name if name and not _DEVANAGARI.search(name) else ""
    )
    return name_mr or name_en or fallback, name_en or name_mr or fallback


def _centre(el: dict[str, Any]) -> tuple[float, float] | None:
    if "lon" in el and "lat" in el:
        return float(el["lon"]), float(el["lat"])
    c = el.get("center")
    if isinstance(c, dict) and "lon" in c and "lat" in c:
        return float(c["lon"]), float(c["lat"])
    return None


def _line(el: dict[str, Any]) -> list[list[float]] | None:
    pts = [[float(p["lon"]), float(p["lat"])] for p in el.get("geometry") or []]
    return pts if len(pts) >= 2 else None


def _ring(el: dict[str, Any]) -> list[list[float]] | None:
    pts = _line(el)
    if pts is None:
        return None
    if pts[0] != pts[-1]:
        pts = [*pts, pts[0]]
    return pts if len(pts) >= 4 else None


def _feature(
    el: dict[str, Any],
    kind: str,
    geometry: dict[str, Any],
    attrs: dict[str, Any],
    mr_fallback: str,
    en_fallback: str,
    *,
    sensitive: bool = False,
) -> dict[str, Any]:
    tags = {str(k): str(v) for k, v in (el.get("tags") or {}).items()}
    name_mr, name_en = _names(tags, "")
    return {
        "type": "Feature",
        "geometry": geometry,
        "properties": {
            "id": f"osm_{el['type']}_{el['id']}",
            "kind": kind,
            "district": "Nashik",
            "tag_hint": "none",
            "sensitive": sensitive,
            "confidence": "low",
            "check_status": "to_verify",
            "attrs": attrs,
            "name_en": name_en or en_fallback,
            "name_mr": name_mr or mr_fallback,
        },
    }


def convert_element(el: dict[str, Any]) -> dict[str, Any] | None:
    """One Overpass element as a GeoJSON feature, or None when it is not something we use."""
    tags = {str(k): str(v) for k, v in (el.get("tags") or {}).items()}
    if "type" not in el or "id" not in el:
        return None

    if tags.get("man_made") == "water_well":
        c = _centre(el)
        if c is None:
            return None
        return _feature(
            el,
            "well",
            {"type": "Point", "coordinates": list(c)},
            {},
            "विहीर (OpenStreetMap)",
            "Well (OpenStreetMap)",
        )

    if tags.get("waterway") in {"dam", "weir"}:
        c = _centre(el)
        if c is None:
            return None
        return _feature(
            el,
            "water_structure",
            {"type": "Point", "coordinates": list(c)},
            {},
            "बंधारा (OpenStreetMap)",
            "Dam or weir (OpenStreetMap)",
        )

    if tags.get("natural") == "water":
        c = _centre(el)
        if c is None:
            return None
        seasonal = tags.get("intermittent") == "yes" or tags.get("seasonal") == "yes"
        return _feature(
            el,
            "water_body",
            {"type": "Point", "coordinates": list(c)},
            {"perennial": False} if seasonal else {},
            "जलाशय (OpenStreetMap)",
            "Water body (OpenStreetMap)",
        )

    if tags.get("waterway") == "river":
        line = _line(el)
        if line is None:
            return None
        return _feature(
            el,
            "river",
            {"type": "LineString", "coordinates": line},
            {},
            "नदी (OpenStreetMap)",
            "River (OpenStreetMap)",
        )

    if tags.get("boundary") == "protected_area" or tags.get("leisure") == "nature_reserve":
        ring = _ring(el)
        if ring is None:
            return None  # a relation or an open way: its extent is not known, so it is not guessed
        label = " ".join(tags.get(k, "") for k in ("name", "name:en", "protection_title"))
        kind = "wildlife_compartment" if _WILDLIFE.search(label) else "conservation_reserve"
        return _feature(
            el,
            kind,
            {"type": "Polygon", "coordinates": [ring]},
            {},
            "संरक्षित क्षेत्र (OpenStreetMap)",
            "Protected area (OpenStreetMap)",
            sensitive=True,
        )
    return None


def to_dataset(elements: list[dict[str, Any]], *, today: str | None = None) -> dict[str, Any]:
    """A FeatureCollection with the header the loader requires. Duplicate ids are dropped."""
    seen: set[str] = set()
    features: list[dict[str, Any]] = []
    for el in elements:
        f = convert_element(el)
        if f is None or f["properties"]["id"] in seen:
            continue
        seen.add(f["properties"]["id"])
        features.append(f)
    return {
        "type": "FeatureCollection",
        "dataset": DATASET,
        "data_version": "v1",
        "is_sample": False,
        "source": SOURCE,
        "source_date": today or datetime.now(UTC).date().isoformat(),
        "features": features,
    }
