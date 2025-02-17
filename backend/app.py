from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from routers import locations, markers, statistics, travel_plan, visualizers

app = FastAPI(debug=True)

# Allow CORS for frontend requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount the directory containing index.html and index.js
app.mount("/static", StaticFiles(directory="static"), name="static")

# Include the routers from different files
app.include_router(locations.router)
app.include_router(markers.router)
app.include_router(visualizers.router)
app.include_router(travel_plan.router)
app.include_router(statistics.router)


@app.get("/", response_class=HTMLResponse)
async def serve_frontend() -> HTMLResponse:
    """Serve the main HTML file from the static directory"""
    with open("static/index.html", "r", encoding="utf-8") as file:
        html_content = file.read()
    return HTMLResponse(content=html_content)


@app.get("/statistics", response_class=HTMLResponse)
async def serve_statistics() -> HTMLResponse:
    """Serve the statistics HTML file from the static directory"""
    with open("static/statistics.html", "r", encoding="utf-8") as file:
        html_content = file.read()
    return HTMLResponse(content=html_content)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="error")
