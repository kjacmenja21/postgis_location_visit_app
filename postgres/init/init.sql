-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- Table for users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    salt TEXT NOT NULL,
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
    salt TEXT := gen_random_bytes(16)::TEXT;  -- Generate a random salt
    salted_hash TEXT;
BEGIN
    salted_hash := crypt(password || salt, gen_salt('bf'));

    -- Insert the username, password hash, and salt into the users table
    INSERT INTO users (username, password_hash, salt)
    VALUES (username, salted_hash, salt);
END;
$$ LANGUAGE plpgsql;


-- Function to log in a user
CREATE OR REPLACE FUNCTION login_user(
    username_param TEXT,
    password_param TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    stored_hash TEXT;
    stored_salt TEXT;
    is_authenticated BOOLEAN := FALSE;
BEGIN
    -- Retrieve the stored hash and salt from the users table
    SELECT password_hash, salt INTO stored_hash, stored_salt
    FROM users
    WHERE users.username = username_param;

    IF stored_hash IS NOT NULL AND crypt(password_param || stored_salt, stored_hash) = stored_hash THEN
        is_authenticated := TRUE;
    END IF;

    RETURN is_authenticated;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_user_id(
    usrnm TEXT,
    password_param TEXT
) RETURNS INT AS $$
DECLARE
    user_id INT;
BEGIN
    -- Ensure that the login_user function is used to validate credentials
    SELECT id INTO user_id
    FROM users
    WHERE users.username = usrnm
      AND login_user(usrnm, password_param);  -- Use the updated login_user function

    IF user_id IS NULL THEN
        RAISE EXCEPTION 'Invalid username or password';
    END IF;

    RETURN user_id;
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
    visit_date DATE DEFAULT NULL
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
    WHERE locations.user_id = $1;  -- Use $1 to refer to the function parameter
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_nearby_polygons_by_user(
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    distance DOUBLE PRECISION,
    usr_id INTEGER
) RETURNS SETOF jsonb AS $$
BEGIN
    RETURN QUERY
    SELECT jsonb_build_object(
        'polygon', ST_AsGeoJSON(ST_ConvexHull(ST_Collect(p.geometry)))::jsonb,
        'points', jsonb_agg(ST_AsGeoJSON(p.geometry)::jsonb)
    )
    FROM locations p
    WHERE p.user_id = usr_id AND ST_DWithin(
        ST_Transform(p.geometry, 3857),
        ST_Transform(ST_SetSRID(ST_Point(lon, lat), 4326), 3857),
        distance
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
CREATE OR REPLACE FUNCTION remove_marker_by_name(usr_id INT, marker_name TEXT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM locations p
    WHERE p.user_id = usr_id
      AND p.name = marker_name;

    -- Optional: Notify user of success
    RAISE NOTICE 'Marker with name "%" has been removed for user ID %.', marker_name, usr_id;
END;
$$ LANGUAGE plpgsql;

-- Function to generate heatmap data
CREATE OR REPLACE FUNCTION generate_heatmap_data(usr_id INT, distance DOUBLE PRECISION)
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
             WHERE p.user_id = usr_id
               AND ST_DWithin(ST_Transform(locations.geometry, 3857), ST_Transform(p.geometry, 3857), distance)
            ) AS intensity
        FROM locations
        WHERE locations.user_id = usr_id
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

-- Function to draw a polyline for a travel plan
CREATE OR REPLACE FUNCTION generate_travel_plan_polyline(
    usr_id INT,
    coord_type_filter coordinate_type,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    WITH filtered_points AS (
        SELECT
            ST_Y(locations.geometry) AS lon,
            ST_X(locations.geometry) AS lat,
            locations.visit_date,  -- Add visit_date to the selection
            row_number() OVER (ORDER BY locations.visit_date) AS idx
        FROM locations
        WHERE locations.user_id = usr_id
          AND locations.coord_type = coord_type_filter
          AND (start_date IS NULL OR locations.visit_date >= start_date::DATE)
          AND (end_date IS NULL OR locations.visit_date <= end_date::DATE)
    )
    SELECT jsonb_build_object(
        'type', coord_type_filter::text,  -- The type is now directly added here.
        'coordinates', jsonb_agg(
            jsonb_build_object(
                'index', idx,  -- Use the row number as 'index'
                'lon', lon,
                'lat', lat,
                'visit_date', visit_date  -- Add the visit_date field here
            )
        )
    ) INTO result
    FROM filtered_points;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate total number of locations visited
CREATE OR REPLACE FUNCTION get_total_locations(usr_id INT)
RETURNS JSONB AS $$
DECLARE
    total_locations INT;
BEGIN
    SELECT COUNT(*)
    INTO total_locations
    FROM locations p
    WHERE p.user_id = usr_id;

    RETURN jsonb_build_object(
        'user_id', usr_id,
        'total_locations', total_locations
    );
END;
$$ LANGUAGE plpgsql;

-- Function to calculate total distance traveled by a user
CREATE OR REPLACE FUNCTION get_total_distance(usr_id INT)
RETURNS JSONB AS $$
DECLARE
    total_distance FLOAT;
BEGIN
    WITH ordered_points AS (
        SELECT
            geometry,
            LAG(geometry) OVER (ORDER BY visit_date) AS prev_geometry
        FROM locations p
        WHERE p.user_id = usr_id
    )
    SELECT COALESCE(SUM(ST_DistanceSphere(geometry, prev_geometry)), 0)
    INTO total_distance
    FROM ordered_points
    WHERE prev_geometry IS NOT NULL;

    RETURN jsonb_build_object(
        'user_id', usr_id,
        'total_distance_meters', total_distance
    );
END;
$$ LANGUAGE plpgsql;

-- Function to count locations by coordinate type
CREATE OR REPLACE FUNCTION get_locations_by_type(usr_id INT)
RETURNS JSONB AS $$
BEGIN
    RETURN jsonb_agg(
        jsonb_build_object(
            'coord_type', coord_type,
            'count', count
        )
    )
    FROM (
        SELECT coord_type, COUNT(*) AS count
        FROM locations p
        WHERE p.user_id = usr_id
        GROUP BY coord_type
    ) AS type_counts;
END;
$$ LANGUAGE plpgsql;

-- Function to get aggregated user statistics
CREATE OR REPLACE FUNCTION get_user_statistics(usr_id INT)
RETURNS JSONB AS $$
DECLARE
    total_locations JSONB;
    total_distance JSONB;
    locations_by_type JSONB;
BEGIN
    total_locations := get_total_locations(usr_id);
    total_distance := get_total_distance(usr_id);
    locations_by_type := get_locations_by_type(usr_id);

    RETURN jsonb_build_object(
        'user_id', usr_id,
        'statistics', jsonb_build_object(
            'total_locations', total_locations->'total_locations',
            'total_distance_meters', total_distance->'total_distance_meters',
            'locations_by_type', locations_by_type
        )
    );
END;
$$ LANGUAGE plpgsql;


