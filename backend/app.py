from typing import Any

import psycopg2
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse

app = FastAPI()

# Allow CORS for frontend requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Connect to PostgreSQL database
conn = psycopg2.connect("dbname=geoapp user=postgres password=secret host=postgres")


@app.get("/", response_class=HTMLResponse)
async def serve_frontend() -> HTMLResponse:
    with open("index.html", "r", encoding="utf-8") as file:
        html_content = file.read()
    return HTMLResponse(content=html_content)


@app.get("/api/lokacije")
async def get_lokacije() -> list[dict[str, Any]]:
    cur = conn.cursor()
    cur.execute("SELECT * FROM get_lokacije();")
    rows = cur.fetchall()
    cur.close()
    return [{"naziv": r[0], "lon": r[1], "lat": r[2], "opis": r[3]} for r in rows]


@app.post("/api/add_marker")
async def add_marker(request: Request):
    data = await request.json()
    naziv = data.get("naziv")
    opis = data.get("opis")
    lat = data.get("lat")
    lon = data.get("lon")

    # Validate input
    if (
        not naziv
        or not isinstance(lat, (float, int))
        or not isinstance(lon, (float, int))
    ):
        raise HTTPException(status_code=400, detail="Invalid input data")

    cur = conn.cursor()
    try:
        cur.execute("SELECT insert_marker(%s, %s, %s, %s)", (naziv, opis, lat, lon))
        conn.commit()
    except Exception as e:
        conn.rollback()  # Rollback transaction on error
        raise HTTPException(status_code=500, detail="Failed to add marker") from e
    finally:
        cur.close()

    return {"message": "Marker added successfully"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
