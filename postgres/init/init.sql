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

-- Function to get locations with visit date
CREATE OR REPLACE FUNCTION get_lokacije()
RETURNS TABLE (
    naziv VARCHAR,
    lon FLOAT,
    lat FLOAT,
    opis TEXT,
    datum_posjeta DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lokacije.naziv,
        ST_X(lokacije.geometrija)::FLOAT AS lon,
        ST_Y(lokacije.geometrija)::FLOAT AS lat,
        lokacije.opis,
        lokacije.datum_posjeta
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
    lon DOUBLE PRECISION,
    datum_posjeta DATE
) RETURNS VOID AS $$
BEGIN
    INSERT INTO lokacije (naziv, opis, geometrija, datum_posjeta)
    VALUES (naziv, opis, ST_SetSRID(ST_MakePoint(lon, lat), 4326), datum_posjeta);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_nearby_polygons(
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    distance DOUBLE PRECISION
) RETURNS JSONB AS $$
DECLARE
    point_geometria geometry;
BEGIN
    -- Convert the input point to a projected coordinate system (e.g., EPSG:3857)
    point_geometria := ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat), 4326), 3857);
    
    -- Return the polygons and points within the specified distance
    RETURN (
        SELECT jsonb_build_object(
            'polygon', ST_AsGeoJSON(ST_ConvexHull(ST_Collect(p.geometrija)))::jsonb,
            'points', jsonb_agg(ST_AsGeoJSON(p.geometrija)::jsonb)
        )
        FROM lokacije p
        WHERE ST_DWithin(
            ST_Transform(p.geometrija, 3857), -- Transform stored point to EPSG:3857
            point_geometria,
            distance -- distance in meters
        )
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION prevent_duplicate_markers()
RETURNS TRIGGER AS $$
DECLARE
    nearby_count INTEGER;
BEGIN
    -- Check for text field duplication
    IF EXISTS (
        SELECT 1
        FROM lokacije
        WHERE naziv = NEW.naziv
          AND opis = NEW.opis
    ) THEN
        RAISE EXCEPTION 'Duplicate naziv and opis detected';
    END IF;

    -- Check for proximity within 1 meter
    SELECT COUNT(*) INTO nearby_count
    FROM lokacije
    WHERE ST_DWithin(
        geometrija,
        NEW.geometrija, -- Use NEW.geometrija directly
        0.00001 -- Approximation for 1 meter in degrees
    );

    IF nearby_count > 0 THEN
        RAISE EXCEPTION 'Duplicate location detected within 1 meter';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_duplicate_marker_trigger
BEFORE INSERT ON lokacije
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_markers();

CREATE OR REPLACE FUNCTION remove_marker_by_name(marker_name TEXT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM lokacije
    WHERE naziv = marker_name;

    -- Optional: Notify user of success
    RAISE NOTICE 'Marker with name "%" has been removed.', marker_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_heatmap_data(distance DOUBLE PRECISION)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    -- Generate heatmap data by finding nearby points within the specified distance
    -- and calculating the intensity (the number of points within the radius)
    WITH nearby_points AS (
        SELECT
            ST_X(lokacije.geometrija) AS lon,
            ST_Y(lokacije.geometrija) AS lat,
            COUNT(*) OVER (PARTITION BY ST_DWithin(lokacije.geometrija, target.geometrija, distance)) AS intensity
        FROM
            lokacije AS lokacije,
            LATERAL (
                SELECT geometrija
                FROM lokacije
                WHERE ST_DWithin(lokacije.geometrija, geometrija, distance)
            ) AS target
    )
    SELECT jsonb_agg(
        jsonb_build_object(
            'type', 'Feature',
            'geometry', jsonb_build_object(
                'type', 'Point',
                'coordinates', jsonb_build_array(lon, lat)
            ),
            'properties', jsonb_build_object(
                'intensity', intensity
            )
        )
    ) INTO result
    FROM nearby_points;

    RETURN result;
END;
$$ LANGUAGE plpgsql;
