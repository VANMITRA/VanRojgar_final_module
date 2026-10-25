"""Anyone from the 14 dataset villages gets a report with no stored village record; no one else."""

import uuid
from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient

from app.config import get_settings
from app.livelihood.auth import StaticDirectory, UserInfo, create_access_token, get_directory
from app.livelihood.deps import get_store
from app.livelihood.nashik_villages import (
    APPROXIMATE_SOURCE,
    DATASET_VILLAGES,
    TALUKA_TOWNS,
    approximate_village,
)
from app.livelihood.store import InMemoryStore
from app.main import create_app

URL = "/api/v1/livelihood"
PROFILE = {
    "land": {"area_value": 2, "area_unit": "acre"},
    "location": {"lat": 20.2, "lng": 73.83, "source": "gps"},
    "livestock": {"cow": 1},
    "assets": ["well"],
    "money_level": "low",
}


def _user(village_id: str | None) -> UserInfo:
    return UserInfo(str(uuid.uuid4()), "Test CFR holder", village_id, frozenset({"cfr_holder"}))


def _client(monkeypatch: pytest.MonkeyPatch, user: UserInfo) -> TestClient:
    monkeypatch.setenv("VANMITRA_LIVELIHOOD_DEV_USERS", "true")
    get_settings.cache_clear()
    app = create_app()
    store = InMemoryStore()  # one store for the whole test, so a saved plot is still there later
    app.dependency_overrides[get_store] = lambda: store
    app.dependency_overrides[get_directory] = lambda: StaticDirectory([user])
    return TestClient(app)


def _auth(user: UserInfo) -> dict[str, str]:
    return {"Authorization": f"Bearer {create_access_token(user.id)}"}


@pytest.fixture(autouse=True)
def _reset() -> Iterator[None]:
    yield
    get_settings.cache_clear()


def test_the_dataset_is_the_14_villages_of_the_raah_report() -> None:
    assert len(DATASET_VILLAGES) == 14
    assert sorted(TALUKA_TOWNS) == ["deola", "dindori", "trimbakeshwar"]
    for lat, lng in TALUKA_TOWNS.values():
        assert 19.0 < lat < 21.0 and 73.0 < lng < 75.0
    assert {t for t, _, _ in DATASET_VILLAGES} == set(TALUKA_TOWNS)


@pytest.mark.parametrize(
    "vid", ["trimbakeshwar/देवगाव", "Trimbakeshwar/ Devgaon ", "deola/Dongargaon"]
)
def test_a_dataset_village_gets_an_approximate_record_that_says_so(
    vid: str,
) -> None:
    v = approximate_village(vid)
    assert v is not None
    assert (v.centroid_lat, v.centroid_lng) == TALUKA_TOWNS[vid.split("/")[0].lower()]
    assert v.source == APPROXIMATE_SOURCE and v.is_sample is False
    assert v.name_mr and v.name_en


@pytest.mark.parametrize(
    "bad",
    [
        None,
        "",
        "nowhere",
        "mars/olympus",
        "dindori/",
        "/village",
        "dindori/दहेगांव",  # a real village, but not in the dataset
        "nashik/मातोरी",
        "deola/Devgaon",  # right name, wrong block
    ],
)
def test_unknown_taluka_or_missing_village_is_not_invented(bad: str | None) -> None:
    assert approximate_village(bad) is None


def test_report_for_a_real_village_with_a_saved_plot(monkeypatch: pytest.MonkeyPatch) -> None:
    user = _user("dindori/कोचरगाव")
    client = _client(monkeypatch, user)
    assert client.put(f"{URL}/profile", json=PROFILE, headers=_auth(user)).status_code == 200
    r = client.post(f"{URL}/report", json={}, headers=_auth(user))
    assert r.status_code == 200
    body = r.json()
    assert body["header"]["report_level"] == "plot"
    assert body["header"]["name"] == "Test CFR holder"


def test_report_with_no_saved_plot_is_still_served(monkeypatch: pytest.MonkeyPatch) -> None:
    user = _user("deola/वर्षी")
    client = _client(monkeypatch, user)
    r = client.post(f"{URL}/report", json={}, headers=_auth(user))
    assert r.status_code == 200
    assert r.json()["header"]["report_level"] == "village"


def test_a_user_with_no_village_or_an_unknown_taluka_is_refused(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    cases = [(None, "livelihood.no_village"), ("atlantis/x", "livelihood.village_not_found")]
    for vid, key in cases:
        user = _user(vid)
        client = _client(monkeypatch, user)
        r = client.post(f"{URL}/report", json={}, headers=_auth(user))
        assert r.status_code == 422
        assert r.json()["message_key"] == key
