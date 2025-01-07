import psycopg2
from fastapi import APIRouter, Depends, HTTPException, Request

from .util import get_db

router = APIRouter()


@router.post("/api/add_marker")
async def add_marker(
    request: Request, db: psycopg2.extensions.connection = Depends(get_db)
) -> dict[str, str]:
    data = await request.json()
    naziv = data.get("naziv")
    opis = data.get("opis")
    lat = data.get("lat")
    lon = data.get("lon")
    datum_posjeta = data.get("datum_posjeta")  # Optional

    # Validate input
    if (
        not naziv
        or not isinstance(lat, (float, int))
        or not isinstance(lon, (float, int))
    ):
        raise HTTPException(status_code=400, detail="Invalid input data")

    cur = db.cursor()
    try:
        cur.execute(
            "INSERT INTO lokacije (naziv, opis, geometrija, datum_posjeta) VALUES (%s, %s, ST_SetSRID(ST_MakePoint(%s, %s), 4326), %s)",
            (naziv, opis, lon, lat, datum_posjeta),
        )
        db.commit()
    except Exception as e:
        db.rollback()  # Rollback transaction on error
        raise HTTPException(status_code=500, detail="Failed to add marker") from e
    finally:
        cur.close()

    return {"message": "Marker added successfully"}
