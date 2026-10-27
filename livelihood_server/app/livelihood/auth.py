"""
Who is calling.

Two ways in, one at a time:

* PRODUCTION (and the integrated app): the token is the one the Node server issued at sign-in
  (HS256, claims `sub` = the user's id, `role`, `exp`), signed with the secret both servers share
  (`VANMITRA_JWT_SECRET` here = `JWT_SECRET` there). The user is then looked up in the SAME MongoDB
  the Node server uses (collection `users`) to learn the name and the village. Nothing is
  stored twice and there is one sign-in.
* DEVELOPMENT and tests (`VANMITRA_LIVELIHOOD_DEV_USERS=true`): built-in users and tokens minted by
  `create_access_token`. Refused in production.

Only a CFR holder (a farmer with community forest rights) may use this module, for their OWN land.
Farmers, the Gram Sabha and buyers get the marketplace only.
"""

import uuid
from datetime import UTC, datetime, timedelta
from functools import lru_cache
from typing import Annotated, Any, Protocol

import jwt
from bson import ObjectId
from bson.errors import InvalidId
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pymongo import MongoClient

from ..config import get_settings
from ..errors import ApiError
from .identity import UserInfo

ALLOWED_ROLES = frozenset({"cfr_holder"})
_bearer = HTTPBearer(auto_error=False)


class UserDirectory(Protocol):
    def get(self, user_id: str) -> UserInfo | None: ...


class EmptyDirectory:
    """Knows nobody. The safe default: every request is refused until a directory is wired."""

    def get(self, user_id: str) -> UserInfo | None:
        return None


# Built-in DEVELOPMENT users (only when VANMITRA_LIVELIHOOD_DEV_USERS=true; refused in production).
DEV_VILLAGER = UserInfo(  # the name is old: this is a CFR holder, the only role served
    "00000000-0000-7000-8000-000000000001",
    "Demo CFR holder",
    "sample_ozhar",
    frozenset({"cfr_holder"}),
)
DEV_VILLAGER_2 = UserInfo(
    "00000000-0000-7000-8000-000000000002",
    "Second CFR holder",
    "sample_ozhar",
    frozenset({"cfr_holder"}),
)
DEV_FARMER = UserInfo(  # roles this module does not serve: farmer, Gram Sabha, buyer
    "00000000-0000-7000-8000-000000000003",
    "Demo farmer",
    "sample_ozhar",
    frozenset({"villager"}),
)
DEV_GRAM_SABHA = UserInfo(
    "00000000-0000-7000-8000-000000000004",
    "Demo Gram Sabha",
    "sample_ozhar",
    frozenset({"gram_sabha"}),
)
DEV_BUYER = UserInfo(
    "00000000-0000-7000-8000-000000000005",
    "Demo buyer",
    None,
    frozenset({"buyer"}),
)
DEV_OFFICER = UserInfo(  # a role this module does not serve
    "00000000-0000-7000-8000-000000000009",
    "Sub-divisional officer",
    None,
    frozenset({"sdo"}),
)


class StaticDirectory:
    def __init__(self, users: list[UserInfo]) -> None:
        self._users = {u.id: u for u in users}

    def get(self, user_id: str) -> UserInfo | None:
        return self._users.get(user_id)


# The Node server's role names -> this module's.
_ROLE_NAMES = {
    "villager": "cfr_holder",  # the Farmer role is gone: an old account is a CFR holder
    "gramsabha": "gram_sabha",
    "cfrholder": "cfr_holder",
}


def village_slug(taluka: str | None, village: str | None) -> str | None:
    """The id of a village in this module's data: "taluka/village", lower case, single spaces."""
    parts = [" ".join((p or "").lower().split()) for p in (taluka, village)]
    return "/".join(parts) if all(parts) else None


class MongoUserDirectory:
    """The Node server's `users` collection, read-only. Needs no write access."""

    def __init__(self, collection: Any) -> None:
        self._users = collection

    def get(self, user_id: str) -> UserInfo | None:
        try:
            oid = ObjectId(user_id)
        except (InvalidId, TypeError):
            return None
        doc = self._users.find_one({"_id": oid})
        if doc is None or doc.get("status") == "suspended":
            return None
        role = _ROLE_NAMES.get(str(doc.get("role")), str(doc.get("role")))
        return UserInfo(
            id=user_id,
            name=str(doc.get("name") or ""),
            village_id=village_slug(doc.get("taluka"), doc.get("village")),
            roles=frozenset({role}),
        )


@lru_cache
def _mongo_users() -> Any:
    settings = get_settings()
    client: MongoClient[dict[str, Any]] = MongoClient(
        settings.mongodb_uri,
        serverSelectionTimeoutMS=settings.db_connect_timeout_s * 1000,
        appname="vanrozgar-livelihood-auth",
    )
    return client[settings.mongodb_db][settings.users_collection]


def get_directory() -> UserDirectory:
    settings = get_settings()
    if settings.livelihood_dev_users:
        return StaticDirectory(
            [DEV_VILLAGER, DEV_VILLAGER_2, DEV_FARMER, DEV_GRAM_SABHA, DEV_BUYER, DEV_OFFICER]
        )
    return MongoUserDirectory(_mongo_users())


def create_access_token(user_id: str | uuid.UUID, *, minutes: int | None = None) -> str:
    """Mint a token in the host's format. For development scripts and tests only."""
    settings = get_settings()
    issued = datetime.now(UTC)
    payload = {
        "sub": str(user_id),
        "type": "access",
        "iat": issued,
        "exp": issued
        + timedelta(minutes=settings.access_token_minutes if minutes is None else minutes),
        "jti": uuid.uuid4().hex,
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> str:
    """The user id in a token. Development tokens carry `type: access`; the Node server's tokens
    do not, and name the user with a 24-character id."""
    settings = get_settings()
    dev = settings.livelihood_dev_users
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=[settings.jwt_algorithm],
            options={"require": ["sub", "type", "exp"] if dev else ["sub", "exp"]},
        )
    except jwt.ExpiredSignatureError as exc:
        raise ApiError(401, "TOKEN_EXPIRED", "auth.token_expired") from exc
    except jwt.PyJWTError as exc:
        raise ApiError(401, "TOKEN_INVALID", "auth.token_invalid") from exc
    if dev and payload.get("type") != "access":
        raise ApiError(401, "TOKEN_INVALID", "auth.token_invalid")
    sub = payload["sub"]
    if not isinstance(sub, str) or not sub:
        raise ApiError(401, "TOKEN_INVALID", "auth.token_invalid")
    return sub


def get_current_user(
    creds: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
    directory: Annotated[UserDirectory, Depends(get_directory)],
) -> UserInfo:
    if creds is None:
        raise ApiError(401, "NOT_AUTHENTICATED", "auth.required")
    user = directory.get(decode_access_token(creds.credentials))
    if user is None:
        raise ApiError(401, "NOT_AUTHENTICATED", "auth.required")
    if not (user.roles & ALLOWED_ROLES):
        raise ApiError(403, "FORBIDDEN", "livelihood.role_not_allowed")
    return user
