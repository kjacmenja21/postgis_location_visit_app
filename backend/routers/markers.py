from datetime import date
from typing import Literal, Optional

import psycopg2
from fastapi import APIRouter, Depends, HTTPException

from .util import UserCredentials, get_db, get_user

router = APIRouter()


class AddMarker(UserCredentials):
    name: str
    description: str
    lat: float
    lon: float
    coord_type: Literal["wishlist"] | Literal["visited"]
    visit_date: Optional[date]


class DeleteMarker(UserCredentials):
    name: str


@router.post("/api/add_marker")
async def add_marker(
    body: AddMarker,
    db: psycopg2.extensions.connection = Depends(get_db),
) -> dict[str, str]:

    cur = db.cursor()
    try:
        user_id = get_user(body.username, body.password, cur)
        cur.execute(
            "SELECT insert_marker(%s, %s, %s, %s, %s, %s, %s)",
            (
                user_id,
                body.name,
                body.description,
                body.lat,
                body.lon,
                body.coord_type,
                body.visit_date,
            ),
        )
        db.commit()
    except HTTPException as e:
        raise e
    except Exception as e:
        db.rollback()  # Rollback transaction on error
        raise HTTPException(status_code=500, detail=str(e)) from e
    finally:
        cur.close()

    return {"message": "Marker added successfully"}


@router.delete("/api/remove_marker")
async def remove_marker(
    body: DeleteMarker,
    db: psycopg2.extensions.connection = Depends(get_db),
) -> dict[str, str]:

    # Validate input
    if not body.name:
        raise HTTPException(status_code=400, detail="Marker name is required")

    cur = db.cursor()
    try:
        user_id = get_user(body.username, body.password, cur)
        # Call the remove_marker_by_name function in the database
        cur.execute("SELECT remove_marker_by_name(%s,%s)", (user_id, body.name))
        db.commit()

    except Exception as e:
        db.rollback()  # Rollback transaction on other errors
        raise HTTPException(status_code=500, detail="Failed to remove marker") from e
    finally:
        cur.close()

    return {"message": f"Marker '{body.name}' removed successfully"}
