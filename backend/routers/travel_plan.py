import logging
from datetime import date
from typing import Literal, Optional

import psycopg2
from fastapi import APIRouter, Depends, HTTPException
from routers.util import UserCredentials, get_db, get_user

logger = logging.getLogger("uvicorn.error")
router = APIRouter()


class TravelPlan(UserCredentials):
    coord_type: Literal["wishlist"] | Literal["visited"]
    start_date: Optional[date] = None
    end_date: Optional[date] = None


@router.post("/api/travel_plan")
def get_travel_plan_line(
    body: TravelPlan,
    db: psycopg2.extensions.connection = Depends(get_db),
):
    cur = db.cursor()
    try:
        user_id = get_user(body.username, body.password, cur)
        logger.debug(user_id)
        logger.debug(body)
        cur.execute(
            "SELECT * FROM generate_travel_plan_polyline(%s, %s, %s, %s);",
            (user_id, body.coord_type, body.start_date, body.end_date),
        )

        rows = cur.fetchall()

    except Exception as e:
        raise HTTPException(
            status_code=500, detail="Failed to fetch nearby polygons"
        ) from e
    finally:
        cur.close()

    return {"type": body.coord_type, "data": rows}
