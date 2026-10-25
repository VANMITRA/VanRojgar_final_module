"""Open-Meteo weather: right averages, bad data refused, a failure never breaks a report."""

from collections.abc import Iterator
from datetime import date
from typing import Any

import pytest
from fastapi.testclient import TestClient

from app.config import get_settings
from app.livelihood import climate
from app.livelihood.auth import DEV_VILLAGER, create_access_token
from app.livelihood.deps import get_store
from app.livelihood.store import InMemoryStore
from app.main import create_app


def _daily(
    years: range, *, rain_by_month: dict[int, float], tmax_by_month: dict[int, float]
) -> dict[str, Any]:
    """Thirty days per month, so the monthly rain total is 30 x the daily value."""
    times: list[str] = []
    rain: list[float | None] = []
    tmax: list[float | None] = []
    for y in years:
        for m in range(1, 13):
            for d in range(1, 31):
                times.append(f"{y}-{m:02d}-{d:02d}")
                rain.append(rain_by_month[m])
                tmax.append(tmax_by_month[m])
    return {"time": times, "precipitation_sum": rain, "temperature_2m_max": tmax}


RAIN = {m: 0.0 for m in range(1, 13)} | {7: 30.0}  # 900 mm in July, none elsewhere
TMAX = {m: 30.0 for m in range(1, 13)} | {5: 41.5}


@pytest.fixture(autouse=True)
def _fresh() -> Iterator[None]:
    climate.clear_cache()
    yield
    climate.clear_cache()
    get_settings.cache_clear()


def test_monthly_averages_across_the_years() -> None:
    w = climate.aggregate(
        _daily(range(2019, 2024), rain_by_month=RAIN, tmax_by_month=TMAX), 2019, 2023
    )
    assert w is not None and w.is_sample is False
    assert len(w.months) == 12
    by = {m.month: m for m in w.months}
    assert by[7].rain_mm == 900 and by[1].rain_mm == 0
    assert by[5].tmax_c == 41.5 and by[2].tmax_c == 30.0
    assert w.source == "Open-Meteo.com (CC BY 4.0), daily data 2019 to 2023"


def test_a_month_with_too_few_days_is_not_guessed() -> None:
    daily = _daily(range(2022, 2024), rain_by_month=RAIN, tmax_by_month=TMAX)
    keep = [i for i, t in enumerate(daily["time"]) if t[5:7] != "03"]  # March is missing entirely
    thin = {k: [v[i] for i in keep] for k, v in daily.items()}
    assert climate.aggregate(thin, 2022, 2023) is None


@pytest.mark.parametrize(
    "bad",
    [
        {},
        {"time": [], "precipitation_sum": [], "temperature_2m_max": []},
        {
            "time": ["2023-01-01"],
            "precipitation_sum": [1.0],
            "temperature_2m_max": [],
        },  # lengths differ
        {"time": ["2023-01-01"], "precipitation_sum": "x", "temperature_2m_max": [1.0]},
    ],
)
def test_malformed_answers_are_refused(bad: dict[str, Any]) -> None:
    assert climate.aggregate(bad, 2019, 2023) is None


def test_null_days_are_skipped_not_counted_as_zero() -> None:
    daily = _daily(range(2022, 2024), rain_by_month=RAIN, tmax_by_month=TMAX)
    for i, t in enumerate(daily["time"]):
        if t[5:7] == "07" and t.endswith(("-01", "-02", "-03")):
            daily["precipitation_sum"][i] = None  # three missing days in July
    w = climate.aggregate(daily, 2022, 2023)
    assert w is not None
    assert {m.month: m.rain_mm for m in w.months}[
        7
    ] == 810  # 27 days x 30 mm: the gaps are not zeros


def test_normals_asks_for_the_last_five_full_years_and_caches() -> None:
    urls: list[str] = []

    def fetch(url: str) -> dict[str, Any]:
        urls.append(url)
        return {"daily": _daily(range(2020, 2025), rain_by_month=RAIN, tmax_by_month=TMAX)}

    first = climate.monthly_normals(19.99, 73.79, fetch=fetch, today=date(2026, 10, 25), now=1000.0)
    again = climate.monthly_normals(19.97, 73.81, fetch=fetch, today=date(2026, 10, 25), now=2000.0)
    assert first is not None and again is first and len(urls) == 1, (
        "same 0.1 degree cell is fetched once"
    )
    assert "start_date=2021-01-01" in urls[0] and "end_date=2025-12-31" in urls[0]
    assert "latitude=20.0" in urls[0] and "longitude=73.8" in urls[0]
    later = climate.monthly_normals(
        19.99, 73.79, fetch=fetch, today=date(2026, 10, 25), now=1000.0 + 31 * 86400
    )
    assert later is not None and len(urls) == 2, "an old entry is fetched again"


def test_a_failing_service_gives_none_and_is_not_cached() -> None:
    def boom(url: str) -> dict[str, Any]:
        raise TimeoutError

    assert climate.monthly_normals(19.99, 73.79, fetch=boom) is None
    ok = climate.monthly_normals(
        19.99,
        73.79,
        fetch=lambda u: {
            "daily": _daily(range(2020, 2025), rain_by_month=RAIN, tmax_by_month=TMAX)
        },
    )
    assert ok is not None


def _report(monkeypatch: pytest.MonkeyPatch, *, live: bool) -> dict[str, Any]:
    monkeypatch.setenv("VANMITRA_LIVELIHOOD_DEV_USERS", "true")
    monkeypatch.setenv("VANMITRA_LIVELIHOOD_LIVE_WEATHER", "true" if live else "false")
    get_settings.cache_clear()
    app = create_app()
    app.dependency_overrides[get_store] = lambda: InMemoryStore()
    client = TestClient(app)
    headers = {"Authorization": f"Bearer {create_access_token(DEV_VILLAGER.id)}"}
    return client.post("/api/v1/livelihood/report", json={}, headers=headers).json()  # type: ignore[no-any-return]


def test_the_report_keeps_the_labelled_sample_weather_unless_live_weather_is_on(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    body = _report(monkeypatch, live=False)
    assert body["weather"]["is_sample"] is True and body["weather"]["source"] is None


def test_the_report_uses_real_weather_when_on_and_the_sample_when_the_service_fails(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    real = climate.aggregate(
        _daily(range(2019, 2024), rain_by_month=RAIN, tmax_by_month=TMAX), 2019, 2023
    )
    monkeypatch.setattr(climate, "monthly_normals", lambda lat, lng: real)
    body = _report(monkeypatch, live=True)
    assert body["weather"]["is_sample"] is False
    assert body["weather"]["source"].startswith("Open-Meteo.com")

    monkeypatch.setattr(climate, "monthly_normals", lambda lat, lng: None)  # the service is down
    body = _report(monkeypatch, live=True)
    assert body["weather"]["is_sample"] is True, "a failed weather call must not break the report"
