"""
The villages this module serves: the 14 Community Forest Resource villages of the Raah Foundation
report (1 October 2026), in the Deola, Dindori and Trimbakeshwar blocks of Nashik district. No other
village is served; this is the whole dataset (the same 14 as the marketplace server).

The report gives no map position, so each village is centred on its BLOCK TOWN, an
approximation, and the village record says so in its `source`. A person who saves their plot
location (GPS, pin or typed) is searched around that location instead, which is the honest way
to use this module.
"""

from .schemas import VillageGeo

# Block town (the usual office location), as (latitude, longitude). Approximate, to about 2 km.
TALUKA_TOWNS: dict[str, tuple[float, float]] = {
    "deola": (20.5170, 74.1500),
    "dindori": (20.2020, 73.8330),
    "trimbakeshwar": (19.9322, 73.5307),
}

# (taluka, English name, Marathi name), in the order of the report's table
DATASET_VILLAGES: tuple[tuple[str, str, str], ...] = (
    ("deola", "Dongargaon", "डोंगरगाव"),
    ("deola", "Kanchane", "कांचने"),
    ("deola", "Kumbharde", "कुंभार्डे"),
    ("deola", "Varshi", "वर्षी"),
    ("dindori", "Bhatode", "भाटोडे"),
    ("dindori", "Kochargaon", "कोचरगाव"),
    ("trimbakeshwar", "Ambai", "अंबाई"),
    ("trimbakeshwar", "Chakore", "चाकोरे"),
    ("trimbakeshwar", "Devgaon", "देवगाव"),
    ("trimbakeshwar", "Met Chandrachi", "मेट चंद्राची"),
    ("trimbakeshwar", "Pahine", "पहिने"),
    ("trimbakeshwar", "Take Harsh", "टाके हर्ष"),
    ("trimbakeshwar", "Talwade", "तळवाडे"),
    ("trimbakeshwar", "Waghera", "वाघेरा"),
)

APPROXIMATE_SOURCE = (
    "Approximate: the centre of the block town, not of the village. "
    "Add your plot's location for a report about your own land."
)

SOURCE_DATE = "2026-10-01"


def _norm(text: str) -> str:
    return " ".join(text.lower().split())


_BY_KEY: dict[tuple[str, str], tuple[str, str, str]] = {}
for _row in DATASET_VILLAGES:
    _BY_KEY[(_row[0], _norm(_row[1]))] = _row
    _BY_KEY[(_row[0], _norm(_row[2]))] = _row


def approximate_village(village_id: str | None) -> VillageGeo | None:
    """A record for "taluka/village" (Marathi or English name); None if it is not one of the 14."""
    if not village_id or "/" not in village_id:
        return None
    taluka, _, name = village_id.partition("/")
    row = _BY_KEY.get((_norm(taluka), _norm(name)))
    if row is None:
        return None
    lat, lng = TALUKA_TOWNS[row[0]]
    return VillageGeo(
        village_id=village_id,
        name_mr=row[2],
        name_en=row[1],
        centroid_lat=lat,
        centroid_lng=lng,
        source=APPROXIMATE_SOURCE,
        source_date=SOURCE_DATE,
        is_sample=False,
    )
