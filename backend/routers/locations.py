from typing import Any

import psycopg2
from fastapi import APIRouter, Depends, HTTPException

from .util import UserCredentials, get_db

router = APIRouter()


@router.post("/api/locations", response_model=list[dict[str, Any]])
async def get_lokacije(
    credentials: UserCredentials,
    db: psycopg2.extensions.connection = Depends(get_db),
) -> list[dict[str, Any]]:
    """Fetch all locations for a given user."""
    cur = db.cursor()
    user_id = None

    try:
        # Find the user ID by username and password
        cur.execute(
            "SELECT get_user_id(%s, %s);", (credentials.username, credentials.password)
        )
        user_id = cur.fetchone()[0]

        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid username or password")

        # Fetch locations for the user
        cur.execute("SELECT * FROM get_user_locations(%s);", (user_id,))
        rows = cur.fetchall()

    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch locations") from e
    finally:
        cur.close()

    return [
        {
            "naziv": r[0],
            "lon": r[1],
            "lat": r[2],
            "opis": r[3],
            "datum_posjeta": r[4],
            "tip_koordinate": r[5],
        }
        for r in rows
    ]
