"""
Typical monthly weather for a place, from Open-Meteo's free historical data (no key; CC BY 4.0, https://open-meteo.com).

This is "typical, from past years, not a forecast" (rule L1): the average rain and the average daily
maximum temperature for each calendar month over the last full years. Any problem (no network, a bad
answer, missing days) returns None and the caller keeps the labelled SAMPLE weather, so a report
never fails or shows made-up numbers because a weather service is down.
"""

import json
import time
import urllib.parse
import urllib.request
from collections import defaultdict
from collections.abc import Callable
from datetime import UTC, date, datetime
from typing import Any

from .schemas import WeatherMonth, WeatherOut

ARCHIVE_URL = "https://archive-api.open-meteo.com/v1/archive"
YEARS = 5
MIN_DAYS_PER_MONTH = 20  # a month with fewer valid days in a year is not trusted
CACHE_SECONDS = 30 * 24 * 3600

Fetcher = Callable[[str], dict[str, Any]]
_cache: dict[tuple[float, float], tuple[float, WeatherOut]] = {}


def source_text(first_year: int, last_year: int) -> str:
    return f"Open-Meteo.com (CC BY 4.0), daily data {first_year} to {last_year}"


def _fetch(url: str) -> dict[str, Any]:
    req = urllib.request.Request(url, headers={"User-Agent": "VanRozgar/1.0 (livelihood report)"})
    with urllib.request.urlopen(req, timeout=8) as resp:  # noqa: S310 (a fixed https address)
        body = json.load(resp)
    return body if isinstance(body, dict) else {}


def aggregate(daily: dict[str, Any], first_year: int, last_year: int) -> WeatherOut | None:
    """Average per calendar month from the `daily` block. None if the data is not enough."""
    times = daily.get("time")
    rain = daily.get("precipitation_sum")
    tmax = daily.get("temperature_2m_max")
    if not (isinstance(times, list) and isinstance(rain, list) and isinstance(tmax, list)):
        return None
    if not (len(times) == len(rain) == len(tmax)):
        return None

    rain_by: dict[tuple[int, int], list[float]] = defaultdict(list)
    tmax_by: dict[tuple[int, int], list[float]] = defaultdict(list)
    for t, r, x in zip(times, rain, tmax, strict=True):
        try:
            y, m = int(str(t)[0:4]), int(str(t)[5:7])
        except ValueError:
            continue
        if isinstance(r, int | float):
            rain_by[(y, m)].append(float(r))
        if isinstance(x, int | float):
            tmax_by[(y, m)].append(float(x))

    months: list[WeatherMonth] = []
    for month in range(1, 13):
        totals = [
            sum(v) for (y, m), v in rain_by.items() if m == month and len(v) >= MIN_DAYS_PER_MONTH
        ]
        means = [
            sum(v) / len(v)
            for (y, m), v in tmax_by.items()
            if m == month and len(v) >= MIN_DAYS_PER_MONTH
        ]
        if not totals or not means:
            return None  # a month with no usable year: do not guess
        months.append(
            WeatherMonth(
                month=month,
                rain_mm=round(sum(totals) / len(totals)),
                tmax_c=round(sum(means) / len(means), 1),
            )
        )
    return WeatherOut(is_sample=False, months=months, source=source_text(first_year, last_year))


def monthly_normals(
    lat: float,
    lng: float,
    *,
    fetch: Fetcher = _fetch,
    today: date | None = None,
    now: float | None = None,
) -> WeatherOut | None:
    """The typical weather around (lat, lng), cached for 30 days per 0.1 degree (about 11 km)."""
    key = (round(lat, 1), round(lng, 1))
    clock = time.time() if now is None else now
    hit = _cache.get(key)
    if hit and clock - hit[0] < CACHE_SECONDS:
        return hit[1]

    last_year = (today or datetime.now(UTC).date()).year - 1  # the last full year
    first_year = last_year - YEARS + 1
    query = urllib.parse.urlencode(
        {
            "latitude": key[0],
            "longitude": key[1],
            "start_date": f"{first_year}-01-01",
            "end_date": f"{last_year}-12-31",
            "daily": "precipitation_sum,temperature_2m_max",
            "timezone": "Asia/Kolkata",
        }
    )
    try:
        body = fetch(f"{ARCHIVE_URL}?{query}")
    except Exception:
        return None
    daily = body.get("daily")
    result = aggregate(daily, first_year, last_year) if isinstance(daily, dict) else None
    if result is not None:
        _cache[key] = (clock, result)
    return result


def clear_cache() -> None:
    _cache.clear()
