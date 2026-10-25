"""The OpenStreetMap converter makes a file the loader accepts, and never invents an extent."""

from typing import Any

from app.livelihood.loader import validate_dataset
from app.livelihood.osm import SOURCE, convert_element, to_dataset

ELEMENTS: list[dict[str, Any]] = [
    {"type": "node", "id": 1, "lat": 19.95, "lon": 73.55, "tags": {"man_made": "water_well"}},
    {
        "type": "way",
        "id": 2,
        "center": {"lat": 19.9, "lon": 73.6},
        "tags": {"natural": "water", "name": "गंगापूर धरण", "intermittent": "yes"},
    },
    {
        "type": "way",
        "id": 3,
        "center": {"lat": 20.0, "lon": 73.7},
        "tags": {"waterway": "dam", "name:en": "Test Dam"},
    },
    {
        "type": "way",
        "id": 4,
        "tags": {"waterway": "river", "name": "Godavari"},
        "geometry": [
            {"lat": 19.9, "lon": 73.5},
            {"lat": 19.92, "lon": 73.52},
            {"lat": 19.95, "lon": 73.6},
        ],
    },
    {
        "type": "way",
        "id": 5,
        "tags": {"boundary": "protected_area", "name": "Kalsubai Wildlife Sanctuary"},
        "geometry": [
            {"lat": 19.5, "lon": 73.6},
            {"lat": 19.5, "lon": 73.7},
            {"lat": 19.6, "lon": 73.7},
            {"lat": 19.6, "lon": 73.6},
        ],
    },
    {
        "type": "way",
        "id": 6,
        "tags": {"leisure": "nature_reserve", "name": "Some Reserve"},
        "geometry": [
            {"lat": 19.7, "lon": 73.4},
            {"lat": 19.7, "lon": 73.5},
            {"lat": 19.8, "lon": 73.5},
            {"lat": 19.8, "lon": 73.4},
        ],
    },
    {"type": "relation", "id": 7, "tags": {"boundary": "protected_area", "name": "A relation"}},
    {"type": "node", "id": 8, "lat": 19.0, "lon": 73.0, "tags": {"amenity": "cafe"}},
    {"type": "node", "id": 1, "lat": 19.95, "lon": 73.55, "tags": {"man_made": "water_well"}},
]


def test_the_converted_file_passes_the_loaders_own_checks() -> None:
    report = validate_dataset(to_dataset(ELEMENTS, today="2026-10-25"))
    assert report.header_errors == []
    assert report.rejected == [], [r.reason for r in report.rejected]
    kinds = report.counts_by_kind()
    assert kinds == {
        "well": 1,
        "water_body": 1,
        "water_structure": 1,
        "river": 1,
        "wildlife_compartment": 1,
        "conservation_reserve": 1,
    }


def test_everything_is_labelled_low_confidence_unverified_and_credited() -> None:
    ds = to_dataset(ELEMENTS)
    assert ds["is_sample"] is False and ds["source"] == SOURCE
    for f in ds["features"]:
        p = f["properties"]
        assert p["confidence"] == "low" and p["check_status"] == "to_verify"
        assert p["id"].startswith("osm_")


def test_protected_areas_stay_visible_to_reports_and_a_relation_is_not_guessed() -> None:
    ds = to_dataset(ELEMENTS)
    protected = [
        f for f in ds["features"] if f["properties"]["kind"].endswith(("reserve", "compartment"))
    ]
    # a `sensitive` resource is hidden from every report, and the wildlife check needs these
    assert len(protected) == 2 and not any(f["properties"]["sensitive"] for f in protected)
    assert convert_element(ELEMENTS[6]) is None  # no extent known, so nothing is invented


def test_duplicates_and_unrelated_things_are_dropped() -> None:
    ds = to_dataset(ELEMENTS)
    assert len(ds["features"]) == 6
    assert convert_element(ELEMENTS[7]) is None


def test_names_keep_marathi_and_english_apart() -> None:
    by_id = {f["properties"]["id"]: f["properties"] for f in to_dataset(ELEMENTS)["features"]}
    assert by_id["osm_way_2"]["name_mr"] == "गंगापूर धरण"
    assert by_id["osm_way_3"]["name_en"] == "Test Dam"
    assert by_id["osm_way_2"]["attrs"] == {"perennial": False}  # intermittent water


def test_a_listed_resource_carries_a_rounded_map_point_and_a_sensitive_one_does_not() -> None:
    from app.livelihood.schemas import ResourceRecord
    from app.livelihood.service import map_point

    def record(geometry: dict[str, Any], *, sensitive: bool = False) -> ResourceRecord:
        return ResourceRecord(
            id="r",
            kind="well",
            geometry=geometry,
            source="t",
            sensitive=sensitive,  # type: ignore[arg-type]
        )

    assert map_point(record({"type": "Point", "coordinates": [73.78456, 20.01234]})) == (
        20.012,
        73.785,
    )
    square = {
        "type": "Polygon",
        "coordinates": [[[73.0, 19.0], [73.1, 19.0], [73.1, 19.1], [73.0, 19.1], [73.0, 19.0]]],
    }
    lat, lng = map_point(record(square)) or (0.0, 0.0)
    assert 19.0 < lat < 19.1 and 73.0 < lng < 73.1  # a point inside the shape
    assert map_point(record({"type": "Point", "coordinates": [73.7, 20.0]}, sensitive=True)) is None
