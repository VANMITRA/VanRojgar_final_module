"""One sign-in for both servers: a token issued by the Node server is accepted here, and the user is
looked up in the shared MongoDB (a fake collection stands in for it)."""

from datetime import UTC, datetime, timedelta
from typing import Any

import jwt
import pytest
from bson import ObjectId
from fastapi.testclient import TestClient

from app.config import get_settings
from app.livelihood.auth import MongoUserDirectory, get_directory, village_slug
from app.livelihood.deps import get_store
from app.livelihood.store import InMemoryStore
from app.main import create_app

URL = "/api/v1/livelihood"
SECRET = "shared-secret-between-the-two-servers-0123456789"
VILLAGER = ObjectId()
GRAM_SABHA = ObjectId()
BUYER = ObjectId()
SUSPENDED = ObjectId()


class FakeUsers:
    def __init__(self) -> None:
        self.docs = {
            VILLAGER: {
                "_id": VILLAGER,
                "name": "Sita",
                "role": "villager",
                "taluka": "Trimbak",
                "village": "Harsul",
            },
            GRAM_SABHA: {
                "_id": GRAM_SABHA,
                "name": "Office",
                "role": "gramsabha",
                "taluka": "Peth",
                "village": "Karanjali",
            },
            BUYER: {"_id": BUYER, "name": "Buyer", "role": "buyer"},
            SUSPENDED: {"_id": SUSPENDED, "name": "X", "role": "villager", "status": "suspended"},
        }

    def find_one(self, query: dict[str, Any]) -> dict[str, Any] | None:
        return self.docs.get(query["_id"])


def token(sub: str, role: str = "villager", secret: str = SECRET, minutes: int = 30) -> str:
    now = datetime.now(UTC)
    return jwt.encode(
        {"sub": sub, "role": role, "iat": now, "exp": now + timedelta(minutes=minutes)},
        secret,
        algorithm="HS256",
    )  # the same shape the Node server signs


@pytest.fixture
def client(monkeypatch: pytest.MonkeyPatch) -> Any:
    monkeypatch.setenv("VANMITRA_LIVELIHOOD_DEV_USERS", "false")
    monkeypatch.setenv("VANMITRA_JWT_SECRET", SECRET)
    get_settings.cache_clear()
    app = create_app()
    app.dependency_overrides[get_store] = lambda: InMemoryStore()
    app.dependency_overrides[get_directory] = lambda: MongoUserDirectory(FakeUsers())
    yield TestClient(app)
    get_settings.cache_clear()


def get(client: TestClient, tok: str | None) -> Any:
    headers = {"Authorization": f"Bearer {tok}"} if tok else {}
    return client.get(f"{URL}/profile", headers=headers)


def test_a_node_token_for_a_villager_is_accepted(client: TestClient) -> None:
    r = get(client, token(str(VILLAGER)))
    assert r.status_code == 404  # signed in; no details saved yet


def test_the_gram_sabha_is_accepted_too(client: TestClient) -> None:
    assert get(client, token(str(GRAM_SABHA), "gramsabha")).status_code == 404


def test_a_buyer_is_not_served(client: TestClient) -> None:
    r = get(client, token(str(BUYER), "buyer"))
    assert r.status_code == 403 and r.json()["message_key"] == "livelihood.role_not_allowed"


def test_a_suspended_user_a_stranger_and_a_bad_id_are_refused(client: TestClient) -> None:
    assert get(client, token(str(SUSPENDED))).status_code == 401
    assert get(client, token(str(ObjectId()))).status_code == 401
    assert get(client, token("not-an-object-id")).status_code == 401


def test_a_token_signed_with_another_secret_or_expired_is_refused(client: TestClient) -> None:
    assert get(client, token(str(VILLAGER), secret="x" * 40)).status_code == 401
    assert get(client, token(str(VILLAGER), minutes=-5)).status_code == 401
    assert get(client, None).status_code == 401


def test_a_development_token_is_not_accepted_in_production_mode(client: TestClient) -> None:
    # tokens made by create_access_token carry type=access and a UUID: no user has that id
    dev = jwt.encode(
        {
            "sub": "00000000-0000-7000-8000-000000000001",
            "type": "access",
            "exp": datetime.now(UTC) + timedelta(minutes=5),
        },
        SECRET,
        algorithm="HS256",
    )
    assert get(client, dev).status_code == 401


def test_the_village_id_is_taluka_slash_village() -> None:
    assert village_slug("Trimbak", "Harsul") == "trimbak/harsul"
    assert village_slug("  Peth ", "Kar  anjali") == "peth/kar anjali"
    assert village_slug(None, "x") is None


def test_the_directory_gives_the_name_the_role_and_the_village() -> None:
    users = MongoUserDirectory(FakeUsers())
    sita = users.get(str(VILLAGER))
    assert sita is not None and sita.name == "Sita"
    assert sita.roles == {"villager"} and sita.village_id == "trimbak/harsul"
    office = users.get(str(GRAM_SABHA))
    assert office is not None and office.roles == {"gram_sabha"}
