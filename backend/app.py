import psycopg2
from fastapi import FastAPI
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
async def serve_frontend():
    with open("index.html", "r", encoding="utf-8") as file:
        html_content = file.read()
    return HTMLResponse(content=html_content)


@app.get("/api/lokacije")
async def get_lokacije():
    cur = conn.cursor()
    cur.execute("SELECT * FROM get_lokacije();")
    rows = cur.fetchall()
    cur.close()
    return [{"naziv": r[0], "lon": r[1], "lat": r[2], "opis": r[3]} for r in rows]


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
