from typing import Any, Dict, List

import psycopg2
from fastapi import APIRouter, Depends, HTTPException

from .util import get_db

router = APIRouter()


@router.get("/api/lokacije", response_model=List[Dict[str, Any]])
async def get_lokacije(
    db: psycopg2.extensions.connection = Depends(get_db),
) -> list[dict[str, Any]]:
    """Fetch all locations"""
    cur = db.cursor()
    try:
        cur.execute("SELECT * FROM get_lokacije();")
        rows = cur.fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch locations") from e
    finally:
        cur.close()

    return [
        {"naziv": r[0], "lon": r[1], "lat": r[2], "opis": r[3], "datum_posjeta": r[4]}
        for r in rows
    ]
