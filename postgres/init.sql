-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table for locations
CREATE TABLE lokacije (
    id SERIAL PRIMARY KEY,
    naziv VARCHAR(100),
    opis TEXT,
    geometrija GEOMETRY(Point, 4326),
    datum_posjeta DATE DEFAULT CURRENT_DATE
);

-- Function to get locations
CREATE OR REPLACE FUNCTION get_lokacije()
RETURNS TABLE (naziv VARCHAR, lon FLOAT, lat FLOAT, opis TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT naziv, ST_X(geometrija)::FLOAT, ST_Y(geometrija)::FLOAT, opis
    FROM lokacije;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to set visit date
CREATE OR REPLACE FUNCTION postavi_datum_posjeta()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.datum_posjeta IS NULL THEN
        NEW.datum_posjeta := CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for setting visit date
CREATE TRIGGER datum_posjeta_trigger
BEFORE INSERT ON lokacije
FOR EACH ROW
EXECUTE FUNCTION postavi_datum_posjeta();

-- Create a function to insert markers
CREATE OR REPLACE FUNCTION insert_marker(
    naziv TEXT,
    opis TEXT,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION
) RETURNS VOID AS $$
BEGIN
    INSERT INTO lokacije (naziv, opis, geometrija)
    VALUES (naziv, opis, ST_SetSRID(ST_MakePoint(lon, lat), 4326));
END;
$$ LANGUAGE plpgsql;
