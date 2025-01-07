-- Seeding file for populating the database with sample locations and random dates

-- Helper function to generate random date between 2014 and 2025
CREATE OR REPLACE FUNCTION random_date() RETURNS DATE AS $$
BEGIN
    RETURN CURRENT_DATE - (FLOOR(RANDOM() * (365 * (2025 - 2014)))) * INTERVAL '1 day';
END;
$$ LANGUAGE plpgsql;

-- Inserting sample markers using the insert_marker function with random dates
SELECT insert_marker('Eiffel Tower', 'A wrought-iron lattice tower in Paris, France', 48.8584, 2.2945, random_date());
SELECT insert_marker('Great Wall of China', 'An ancient series of walls and fortifications located in northern China', 40.4319, 116.5704, random_date());
SELECT insert_marker('Statue of Liberty', 'A colossal neoclassical sculpture on Liberty Island in New York City, USA', 40.6892, -74.0445, random_date());
SELECT insert_marker('Machu Picchu', 'An Incan citadel located in the Eastern Andes in Peru', -13.1631, -72.5450, random_date());
SELECT insert_marker('Pyramids of Giza', 'Ancient pyramid structures located in Giza, Egypt', 29.9792, 31.1342, random_date());
SELECT insert_marker('Sydney Opera House', 'A multi-venue performing arts center in Sydney, Australia', -33.8568, 151.2153, random_date());
SELECT insert_marker('Colosseum', 'An ancient amphitheater located in the center of Rome, Italy', 41.8902, 12.4922, random_date());
SELECT insert_marker('Taj Mahal', 'A white marble mausoleum located in Agra, India', 27.1751, 78.0421, random_date());
SELECT insert_marker('Christ the Redeemer', 'A large statue of Jesus Christ in Rio de Janeiro, Brazil', -22.9519, -43.2105, random_date());
SELECT insert_marker('Mount Fuji', 'An active stratovolcano located in Japan', 35.3606, 138.7274, random_date());

-- Zagreb Locations
SELECT insert_marker('Ban Jelačić Square', 'Main square in the center of Zagreb, Croatia', 45.8131, 15.978, random_date());
SELECT insert_marker('Zagreb Cathedral', 'The cathedral of the Archdiocese of Zagreb, Croatia', 45.8138, 15.9786, random_date());
SELECT insert_marker('Maksimir Park', 'The largest park in Zagreb, Croatia', 45.8077, 16.0249, random_date());
SELECT insert_marker('Museum of Broken Relationships', 'Museum dedicated to failed love relationships, located in Zagreb', 45.8133, 15.9761, random_date());
SELECT insert_marker('Upper Town (Gornji Grad)', 'Historic part of Zagreb with cobblestone streets and medieval architecture', 45.8139, 15.9775, random_date());
SELECT insert_marker('Tkalčićeva Street', 'Famous street in Zagreb with numerous bars and restaurants', 45.8134, 15.9797, random_date());
SELECT insert_marker('Zrinjevac Park', 'A beautiful park in the heart of Zagreb, Croatia', 45.8130, 15.9811, random_date());
SELECT insert_marker('Jarun Lake', 'A large lake in Zagreb popular for sports and recreation', 45.7876, 15.9852, random_date());
SELECT insert_marker('King Tomislav Square', 'A public square in Zagreb dedicated to the first Croatian king', 45.8121, 15.9765, random_date());
SELECT insert_marker('Lotrščak Tower', 'A medieval tower in Zagreb, known for the daily cannon shot', 45.8137, 15.9768, random_date());

-- Varaždin Locations
SELECT insert_marker('Varaždin Old Town', 'A medieval fortress and the historic center of Varaždin, Croatia', 46.3056, 16.3372, random_date());
SELECT insert_marker('Varaždin Castle', 'A historic castle located in the center of Varaždin', 46.3066, 16.3394, random_date());
SELECT insert_marker('Trg Kralja Tomislava', 'A central square in Varaždin', 46.3052, 16.3379, random_date());
SELECT insert_marker('Varaždin City Museum', 'Museum dedicated to the history and culture of Varaždin, Croatia', 46.3059, 16.3390, random_date());
SELECT insert_marker('St. Nicholas’ Church', 'A historic church located in the city center of Varaždin', 46.3058, 16.3382, random_date());
SELECT insert_marker('Civic Centre Varaždin', 'A major public space in the city of Varaždin', 46.3051, 16.3373, random_date());
SELECT insert_marker('Park Nezavisnosti', 'A green park area in the city center of Varaždin', 46.3048, 16.3377, random_date());
SELECT insert_marker('Drava River Bank', 'The scenic river bank area in Varaždin, Croatia', 46.3092, 16.3380, random_date());
SELECT insert_marker('Varaždin Cemetery', 'A large historical cemetery located on the outskirts of Varaždin', 46.3113, 16.3486, random_date());
SELECT insert_marker('St. George’s Church', 'An important church located in the city center of Varaždin', 46.3060, 16.3367, random_date());

-- Additional Locations in between Zagreb and Varaždin (within ~50km radius)
SELECT insert_marker('Ludbreg', 'A town located between Zagreb and Varaždin, known for its religious significance', 46.2850, 16.4167, random_date());
SELECT insert_marker('Breznica', 'A small village located south of Varaždin, Croatia', 46.2219, 16.3422, random_date());
SELECT insert_marker('Cakovec', 'The capital of Međimurje County, located between Varaždin and the Hungarian border', 46.3803, 16.4378, random_date());
SELECT insert_marker('Novakovec', 'A small village near Varaždin', 46.2700, 16.3590, random_date());
SELECT insert_marker('Ivanec', 'A town situated to the east of Varaždin, Croatia', 46.2061, 16.3191, random_date());

-- Optional: Retrieve the inserted data to confirm seeding
SELECT 
    id, 
    naziv, 
    LEFT(opis, 20) AS opis,  -- Truncates the description to 100 characters
    ST_X(geometrija) AS lon,
    ST_Y(geometrija) AS lat,
    datum_posjeta
FROM lokacije;
