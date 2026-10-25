"""
[USER RUNS] Build a real resource dataset for Nashik district from OpenStreetMap.

    python scripts/build_osm_resources.py                 # writes data/nashik_osm_resources.geojson
    python scripts/load_livelihood_resources.py data/nashik_osm_resources.geojson    # validate only
    python scripts/load_livelihood_resources.py data/nashik_osm_resources.geojson --apply  # load

It only READS from the public Overpass service (wells, water bodies, dams and weirs, named rivers,
protected areas) and writes one local file; it never touches the database. The public service is
often busy, so each query is retried slowly across a few servers. Please do not run it in a loop.

The result is labelled low confidence and "to verify", and credited to OpenStreetMap contributors
(ODbL, https://www.openstreetmap.org/copyright). Show that credit wherever the data is shown.
"""

import json
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.livelihood.osm import to_dataset  # noqa: E402

SERVERS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.private.coffee/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
]
AREA = 'area["boundary"="administrative"]["admin_level"="5"]["name:en"~"Nashik"]->.a;\n'
QUERIES = {
    "wells, water bodies, dams": (
        "[out:json][timeout:180];\n" + AREA + "(\n"
        '  node["man_made"="water_well"](area.a);\n'
        '  way["natural"="water"](area.a);\n'
        '  way["waterway"~"^(dam|weir)$"](area.a);\n'
        ");\nout center;"
    ),
    "named rivers": (
        "[out:json][timeout:180];\n" + AREA + 'way["waterway"="river"]["name"](area.a);\nout geom;'
    ),
    "protected areas": (
        "[out:json][timeout:180];\n"
        + AREA
        + '(way["boundary"="protected_area"](area.a);way["leisure"="nature_reserve"](area.a););\n'
        "out geom;"
    ),
}
OUT = Path(__file__).resolve().parent.parent / "data" / "nashik_osm_resources.geojson"


def fetch(query: str, attempts: int = 6) -> list[dict[str, Any]]:
    delay = 20
    for attempt in range(1, attempts + 1):
        server = SERVERS[(attempt - 1) % len(SERVERS)]
        req = urllib.request.Request(
            server,
            data=urllib.parse.urlencode({"data": query}).encode(),
            headers={"User-Agent": "VanRozgar-hackathon/1.0 (one-off dataset build)"},
        )
        try:
            with urllib.request.urlopen(req, timeout=240) as resp:  # noqa: S310 (fixed https servers)
                return list(json.load(resp).get("elements", []))
        except Exception as exc:  # busy, timed out or refused: wait and try the next server
            print(f"  attempt {attempt}/{attempts} on {server} failed: {exc}")
            time.sleep(delay)
            delay = min(delay * 2, 240)
    raise SystemExit("Overpass is too busy right now. Try again later.")


def main() -> None:
    elements: list[dict[str, Any]] = []
    for label, query in QUERIES.items():
        print(f"fetching {label} ...")
        found = fetch(query)
        print(f"  {len(found)} elements")
        elements.extend(found)
    dataset = to_dataset(elements)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(dataset, ensure_ascii=False), encoding="utf-8")
    kinds: dict[str, int] = {}
    for f in dataset["features"]:
        kinds[f["properties"]["kind"]] = kinds.get(f["properties"]["kind"], 0) + 1
    print(f"wrote {len(dataset['features'])} features to {OUT}: {kinds}")
    print("Next: validate it with scripts/load_livelihood_resources.py (no --apply).")


if __name__ == "__main__":
    main()
