import json

import httpx
import psycopg2
from fastapi import APIRouter, Depends, HTTPException

from .util import UserCredentials, get_db, get_user

router = APIRouter()


@router.get("/api/get_countries")
async def fetch_and_store_countries(
    db: psycopg2.extensions.connection = Depends(get_db),
):
    """
    Fetch country GeoJSON data from an external source and store it in the database.
    """
    COUNTRY_GEOJSON_URL = "https://raw.githubusercontent.com/johan/world.geo.json/master/countries.geo.json"
    cur = db.cursor()

    async with httpx.AsyncClient() as session:
        response: httpx.Response = await session.get(COUNTRY_GEOJSON_URL)

        if response.status_code != 200:
            raise HTTPException("Failed to fetch GeoJSON data.")

        geojson_data: dict = response.json()

        for feature in geojson_data["features"]:
            country_name = feature["properties"].get("name")
            geometry = json.dumps(feature["geometry"])

            if country_name and geometry:
                cur.execute(
                    """
                    SELECT add_country_geojson(%s, %s);
                    """,
                    (
                        country_name,
                        geometry,
                    ),
                )
    cur.execute("""SELECT COUNT(*) FROM countries;""")
    count = cur.fetchall()[0]
    return f"Added {count} countries."


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
