-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- Table for users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for locations
CREATE TYPE coordinate_type AS ENUM ('visited', 'wishlist');

CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100),
    description TEXT,
    geometry GEOMETRY(Point, 4326),
    visit_date DATE DEFAULT CURRENT_DATE,
    coord_type coordinate_type NOT NULL
);

-- Function to register a user
CREATE OR REPLACE FUNCTION register_user(
    username TEXT,
    password TEXT
) RETURNS VOID AS $$
DECLARE
    salt TEXT := gen_random_bytes(16)::TEXT;
    salted_hash TEXT;
BEGIN
    salted_hash := crypt(password || salt, gen_salt('bf'));

    INSERT INTO users (username, password_hash)
    VALUES (username, salted_hash);
END;
$$ LANGUAGE plpgsql;

-- Function to log in a user
CREATE OR REPLACE FUNCTION login_user(
    username TEXT,
    password TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    stored_hash TEXT;
    is_authenticated BOOLEAN := FALSE;
BEGIN
    SELECT password_hash INTO stored_hash
    FROM users
    WHERE username = username;

    IF stored_hash IS NOT NULL AND crypt(password, stored_hash) = stored_hash THEN
        is_authenticated := TRUE;
    END IF;

    RETURN is_authenticated;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to set visit date
CREATE OR REPLACE FUNCTION set_visit_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.visit_date IS NULL THEN
        NEW.visit_date := CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for setting visit date
CREATE TRIGGER visit_date_trigger
BEFORE INSERT ON locations
FOR EACH ROW
EXECUTE FUNCTION set_visit_date();

-- Function to insert a marker
CREATE OR REPLACE FUNCTION insert_marker(
    user_id INT,
    name TEXT,
    description TEXT,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    coord_type coordinate_type,
    visit_date DATE
) RETURNS VOID AS $$
BEGIN
    INSERT INTO locations (user_id, name, description, geometry, coord_type, visit_date)
    VALUES (user_id, name, description, ST_SetSRID(ST_MakePoint(lon, lat), 4326), coord_type, visit_date);
END;
$$ LANGUAGE plpgsql;

-- Function to get user locations
CREATE OR REPLACE FUNCTION get_user_locations(user_id INT)
RETURNS TABLE (
    name VARCHAR,
    lon FLOAT,
    lat FLOAT,
    description TEXT,
    visit_date DATE,
    coord_type coordinate_type
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        locations.name,
        ST_X(locations.geometry)::FLOAT AS lon,
        ST_Y(locations.geometry)::FLOAT AS lat,
        locations.description,
        locations.visit_date,
        locations.coord_type
    FROM locations
    WHERE locations.user_id = user_id;
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
            'polygon', ST_AsGeoJSON(ST_ConvexHull(ST_Collect(p.geometry)))::jsonb,
            'points', jsonb_agg(ST_AsGeoJSON(p.geometry)::jsonb)
        )
        FROM locations p
        WHERE ST_DWithin(
            ST_Transform(p.geometrija, 3857), -- Transform stored point to EPSG:3857
            point_geometria,
            distance -- distance in meters
        )
    );
END;
$$ LANGUAGE plpgsql;


-- Prevent duplicate markers for a user
CREATE OR REPLACE FUNCTION prevent_duplicate_markers()
RETURNS TRIGGER AS $$
DECLARE
    nearby_count INTEGER;
BEGIN
    -- Check for text field duplication for the same user
    IF EXISTS (
        SELECT 1
        FROM locations
        WHERE name = NEW.name
          AND description = NEW.description
          AND user_id = NEW.user_id
    ) THEN
        RAISE EXCEPTION 'Duplicate name and description detected for this user';
    END IF;

    -- Check for proximity within 1 meter for the same user
    SELECT COUNT(*) INTO nearby_count
    FROM locations
    WHERE user_id = NEW.user_id
      AND ST_DWithin(
          geometry,
          NEW.geometry, -- Use NEW.geometry directly
          0.00001 -- Approximation for 1 meter in degrees
      );

    IF nearby_count > 0 THEN
        RAISE EXCEPTION 'Duplicate location detected within 1 meter for this user';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_duplicate_marker_trigger
BEFORE INSERT ON locations
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_markers();

-- Function to remove a marker by name
CREATE OR REPLACE FUNCTION remove_marker_by_name(user_id INT, marker_name TEXT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM locations
    WHERE user_id = user_id
      AND name = marker_name;

    -- Optional: Notify user of success
    RAISE NOTICE 'Marker with name "%" has been removed for user ID %.', marker_name, user_id;
END;
$$ LANGUAGE plpgsql;

-- Function to generate heatmap data
CREATE OR REPLACE FUNCTION generate_heatmap_data(user_id INT, distance DOUBLE PRECISION)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    WITH nearby_points AS (
        SELECT
            ST_X(locations.geometry) AS lon,
            ST_Y(locations.geometry) AS lat,
            (SELECT COUNT(*)
             FROM locations p
             WHERE p.user_id = user_id
               AND ST_DWithin(locations.geometry, p.geometry, distance)
            ) AS intensity
        FROM locations
        WHERE user_id = user_id
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

