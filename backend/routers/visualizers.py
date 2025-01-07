from typing import Any

import psycopg2
from fastapi import APIRouter, Depends, HTTPException

from .util import get_db

router = APIRouter()


@router.get("/api/nearby_polygons")
async def get_nearby_polygons(
    lat: float,
    lon: float,
    distance: float,
    db: psycopg2.extensions.connection = Depends(get_db),
) -> dict[str, Any]:
    """Fetch polygons within a defined distance from the specified latitude and longitude"""
    cur = db.cursor()
    try:
        # Call the PostgreSQL function to get nearby polygons
        cur.execute(
            "SELECT * FROM get_nearby_polygons(%s, %s, %s);", (lat, lon, distance)
        )
        rows = cur.fetchall()
    except Exception as e:
        raise HTTPException(
            status_code=500, detail="Failed to fetch nearby polygons"
        ) from e
    finally:
        cur.close()

    # Return the GeoJSON polygons as a JSON response
    polygons = [row[0] for row in rows]
    return {"type": "FeatureCollection", "features": polygons}


@router.get("/api/heatmap_data")
async def get_heatmap_data(
    distance: float,
    db: psycopg2.extensions.connection = Depends(get_db),
) -> dict[str, Any]:
    """Fetch heatmap data (clustered points with intensity)"""
    cur = db.cursor()
    try:
        # Call the PostgreSQL function to get heatmap data
        cur.execute("SELECT generate_heatmap_data(%s);", (distance,))
        rows = cur.fetchall()
    except Exception as e:
        raise HTTPException(
            status_code=500, detail="Failed to fetch heatmap data"
        ) from e
    finally:
        cur.close()

    # Extract the heatmap data from the result (which is in JSON format)
    heatmap_data = rows[0][0]  # Get the JSONB result from the query

    return {"type": "FeatureCollection", "features": heatmap_data}
