"""
Villages the report can serve without a stored village record.

The Node server knows 770+ real villages (the district CFR register), but this module's `villages`
collection holds only the ones someone loaded with a surveyed centre and boundary. A person from any
other village must still get a report, so a village record is built on the fly from the
"taluka/village" id on their login. The centre is the TALUKA TOWN, an approximation, and the record
says so in its `source`. A person who saves their plot location (GPS, pin or typed) is searched
around that location instead, which is the honest way to use this module.
"""

from .schemas import VillageGeo

# Taluka town (the usual office location), as (latitude, longitude). Approximate, to about 2 km.
TALUKA_TOWNS: dict[str, tuple[float, float]] = {
    "nashik": (19.9975, 73.7898),
    "dindori": (20.2020, 73.8330),
    "peth": (20.1667, 73.5667),
    "igatpuri": (19.6958, 73.5625),
    "trimbakeshwar": (19.9322, 73.5307),
    "surgana": (20.5667, 73.6000),
    "sinnar": (19.8480, 74.0000),
    "chandwad": (20.3300, 74.2500),
    "kalwan": (20.4900, 74.0500),
    "deola": (20.5170, 74.1500),
    "malegaon": (20.5500, 74.5300),
    "baglan": (20.5900, 74.2000),
    "nandgaon": (20.3050, 74.6560),
    "yeola": (20.0426, 74.4888),
}

APPROXIMATE_SOURCE = (
    "Approximate: the centre of the taluka town, not of the village. "
    "Add your plot's location for a report about your own land."
)


def approximate_village(village_id: str | None) -> VillageGeo | None:
    """A village record for "taluka/village", or None when the taluka is not one of the 14."""
    if not village_id or "/" not in village_id:
        return None
    taluka, _, name = village_id.partition("/")
    town = TALUKA_TOWNS.get(taluka.strip().lower())
    if town is None or not name.strip():
        return None
    return VillageGeo(
        village_id=village_id,
        name_mr=name.strip(),
        name_en=name.strip(),
        centroid_lat=town[0],
        centroid_lng=town[1],
        source=APPROXIMATE_SOURCE,
        source_date="2026-10-25",
        is_sample=False,
    )
