import psycopg2
from fastapi import APIRouter, Depends, HTTPException

from .util import UserCredentials, get_db, get_user

router = APIRouter()


@router.post("/api/statistics")
def get_statistics(
    body: UserCredentials,
    db: psycopg2.extensions.connection = Depends(get_db),
):
    cur = db.cursor()
    try:
        user_id = get_user(body.username, body.password, cur)
        cur.execute(
            "SELECT * FROM get_user_statistics(%s);",
            (user_id,),
        )
        rows = cur.fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch statistics") from e
    finally:
        cur.close()

    return rows
