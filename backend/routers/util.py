import os

import psycopg2
from fastapi import HTTPException


# Create a function to connect to the PostgreSQL database
def get_db():
    try:
        conn = psycopg2.connect(
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT"),
        )
        yield conn
    except Exception as e:
        raise HTTPException(status_code=500, detail="Database connection failed") from e
    finally:
        if conn:
            conn.close()