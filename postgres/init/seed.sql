-- Updated seeding script for populating the database with sample data linked to users and supporting enum and updated schema

-- Helper function to generate random date between 2014 and 2025
CREATE OR REPLACE FUNCTION random_date() RETURNS DATE AS $$
BEGIN
    RETURN CURRENT_DATE - (FLOOR(RANDOM() * (365 * (2025 - 2014)))) * INTERVAL '1 day';
END;
$$ LANGUAGE plpgsql;

-- Create dummy users to associate with locations
SELECT register_user('user1', 'password1');
SELECT register_user('user2', 'password2');
SELECT register_user('user3', 'password3');

-- Inserting sample markers using the insert_marker function with random dates and user associations
SELECT insert_marker(1, 'Eiffel Tower', 'A wrought-iron lattice tower in Paris, France', 48.8584, 2.2945, 'visited', random_date());
SELECT insert_marker(2, 'Great Wall of China', 'An ancient series of walls and fortifications located in northern China', 40.4319, 116.5704, 'wishlist', random_date());
SELECT insert_marker(3, 'Statue of Liberty', 'A colossal neoclassical sculpture on Liberty Island in New York City, USA', 40.6892, -74.0445, 'visited', random_date());
SELECT insert_marker(1, 'Machu Picchu', 'An Incan citadel located in the Eastern Andes in Peru', -13.1631, -72.5450, 'wishlist', random_date());
SELECT insert_marker(2, 'Pyramids of Giza', 'Ancient pyramid structures located in Giza, Egypt', 29.9792, 31.1342, 'visited', random_date());
SELECT insert_marker(3, 'Sydney Opera House', 'A multi-venue performing arts center in Sydney, Australia', -33.8568, 151.2153, 'visited', random_date());
SELECT insert_marker(1, 'Colosseum', 'An ancient amphitheater located in the center of Rome, Italy', 41.8902, 12.4922, 'wishlist', random_date());
SELECT insert_marker(2, 'Taj Mahal', 'A white marble mausoleum located in Agra, India', 27.1751, 78.0421, 'visited', random_date());
SELECT insert_marker(3, 'Christ the Redeemer', 'A large statue of Jesus Christ in Rio de Janeiro, Brazil', -22.9519, -43.2105, 'wishlist', random_date());
SELECT insert_marker(1, 'Mount Fuji', 'An active stratovolcano located in Japan', 35.3606, 138.7274, 'visited', random_date());

-- Zagreb Locations
SELECT insert_marker(2, 'Ban Jelačić Square', 'Main square in the center of Zagreb, Croatia', 45.8131, 15.978, 'visited', random_date());
SELECT insert_marker(1, 'Zagreb Cathedral', 'The cathedral of the Archdiocese of Zagreb, Croatia', 45.8138, 15.9786, 'wishlist', random_date());
SELECT insert_marker(3, 'Maksimir Park', 'The largest park in Zagreb, Croatia', 45.8077, 16.0249, 'visited', random_date());
SELECT insert_marker(2, 'Museum of Broken Relationships', 'Museum dedicated to failed love relationships, located in Zagreb', 45.8133, 15.9761, 'wishlist', random_date());
SELECT insert_marker(1, 'Upper Town (Gornji Grad)', 'Historic part of Zagreb with cobblestone streets and medieval architecture', 45.8139, 15.9775, 'visited', random_date());
SELECT insert_marker(3, 'Tkalčićeva Street', 'Famous street in Zagreb with numerous bars and restaurants', 45.8134, 15.9797, 'wishlist', random_date());
SELECT insert_marker(2, 'Zrinjevac Park', 'A beautiful park in the heart of Zagreb, Croatia', 45.8130, 15.9811, 'visited', random_date());
SELECT insert_marker(1, 'Jarun Lake', 'A large lake in Zagreb popular for sports and recreation', 45.7876, 15.9852, 'wishlist', random_date());
SELECT insert_marker(3, 'King Tomislav Square', 'A public square in Zagreb dedicated to the first Croatian king', 45.8121, 15.9765, 'visited', random_date());
SELECT insert_marker(2, 'Lotrščak Tower', 'A medieval tower in Zagreb, known for the daily cannon shot', 45.8137, 15.9768, 'wishlist', random_date());

-- Varaždin Locations
SELECT insert_marker(1, 'Varaždin Old Town', 'A medieval fortress and the historic center of Varaždin, Croatia', 46.3056, 16.3372, 'visited', random_date());
SELECT insert_marker(2, 'Varaždin Castle', 'A historic castle located in the center of Varaždin', 46.3066, 16.3394, 'wishlist', random_date());
SELECT insert_marker(3, 'Trg Kralja Tomislava', 'A central square in Varaždin', 46.3052, 16.3379, 'visited', random_date());
SELECT insert_marker(1, 'Varaždin City Museum', 'Museum dedicated to the history and culture of Varaždin, Croatia', 46.3059, 16.3390, 'wishlist', random_date());
SELECT insert_marker(2, 'St. Nicholas’ Church', 'A historic church located in the city center of Varaždin', 46.3058, 16.3382, 'visited', random_date());
SELECT insert_marker(3, 'Civic Centre Varaždin', 'A major public space in the city of Varaždin', 46.3051, 16.3373, 'wishlist', random_date());
SELECT insert_marker(1, 'Park Nezavisnosti', 'A green park area in the city center of Varaždin', 46.3048, 16.3377, 'visited', random_date());
SELECT insert_marker(2, 'Drava River Bank', 'The scenic river bank area in Varaždin, Croatia', 46.3092, 16.3380, 'wishlist', random_date());
SELECT insert_marker(3, 'Varaždin Cemetery', 'A large historical cemetery located on the outskirts of Varaždin', 46.3113, 16.3486, 'visited', random_date());
SELECT insert_marker(1, 'St. George’s Church', 'An important church located in the city center of Varaždin', 46.3060, 16.3367, 'wishlist', random_date());

-- Additional Varaždin Locations
SELECT insert_marker(1, 'Varaždin Town Hall', 'A historical building located in the heart of Varaždin with a beautiful clock tower', 46.3036, 16.3402, 'visited', random_date());
SELECT insert_marker(2, 'Varaždin Baroque Ensemble', 'A group of historical buildings showcasing the baroque architectural style of Varaždin', 46.3054, 16.3386, 'wishlist', random_date());
SELECT insert_marker(3, 'Varaždin Synagogue', 'The historical synagogue of Varaždin, an important cultural landmark', 46.3063, 16.3378, 'visited', random_date());
SELECT insert_marker(1, 'Varaždin Cathedral', 'The Cathedral of St. Nicholas, a prominent baroque church in Varaždin', 46.3049, 16.3381, 'wishlist', random_date());
SELECT insert_marker(2, 'Varaždin Train Station', 'A railway station connecting Varaždin to other major Croatian cities', 46.3019, 16.3418, 'visited', random_date());
SELECT insert_marker(3, 'Varaždin City Park', 'A spacious park ideal for relaxation and outdoor activities', 46.3053, 16.3407, 'wishlist', random_date());
SELECT insert_marker(1, 'Varaždin Water Tower', 'A historic water tower providing panoramic views of the city', 46.3069, 16.3412, 'visited', random_date());
SELECT insert_marker(2, 'Varaždin Library', 'A modern library located near the town square, offering a wide range of books and digital media', 46.3045, 16.3395, 'wishlist', random_date());
SELECT insert_marker(3, 'Varaždin Bridge', 'A bridge connecting the two parts of the city, with beautiful views of the Drava River', 46.3075, 16.3390, 'visited', random_date());
SELECT insert_marker(1, 'Varaždin Observation Deck', 'A lookout point with a panoramic view of the city and surrounding countryside', 46.3072, 16.3365, 'wishlist', random_date());
SELECT insert_marker(2, 'Varaždin Theater', 'A historic theater showcasing local performances and international plays', 46.3032, 16.3400, 'visited', random_date());
SELECT insert_marker(3, 'Varaždin Aquatic Center', 'A large sports complex with swimming pools and recreational facilities', 46.3080, 16.3358, 'wishlist', random_date());
SELECT insert_marker(1, 'Varaždin Outdoor Market', 'A popular market where locals sell fresh produce, flowers, and handmade goods', 46.3041, 16.3384, 'visited', random_date());
SELECT insert_marker(2, 'Varaždin Historical Society', 'A museum dedicated to the history of Varaždin, its people, and their culture', 46.3030, 16.3364, 'wishlist', random_date());
SELECT insert_marker(3, 'Varaždin Amphitheater', 'An ancient Roman amphitheater that hosts various events and concerts', 46.3090, 16.3440, 'visited', random_date());
SELECT insert_marker(1, 'Varaždin Golf Course', 'A scenic golf course located just outside the city', 46.3070, 16.3405, 'wishlist', random_date());
SELECT insert_marker(2, 'Varaždin Brewery', 'A historical brewery known for producing some of the best local beer in Varaždin', 46.3050, 16.3422, 'visited', random_date());
SELECT insert_marker(3, 'Varaždin Zoo', 'A small zoo that features native Croatian wildlife as well as exotic animals', 46.3100, 16.3450, 'wishlist', random_date());
SELECT insert_marker(1, 'Varaždin Botanical Garden', 'A beautiful botanical garden showcasing a variety of plants and flowers', 46.3057, 16.3360, 'visited', random_date());
SELECT insert_marker(2, 'Varaždin City Hall', 'A historical city hall, now a cultural center and event space', 46.3042, 16.3405, 'wishlist', random_date());
SELECT insert_marker(3, 'Varaždin Nature Reserve', 'A nature reserve located just outside the city, ideal for hiking and bird watching', 46.3115, 16.3510, 'visited', random_date());


-- Additional Locations in between Zagreb and Varaždin (within ~50km radius)
SELECT insert_marker(2, 'Ludbreg', 'A town located between Zagreb and Varaždin, known for its religious significance', 46.2850, 16.4167, 'visited', random_date());
SELECT insert_marker(3, 'Breznica', 'A small village located south of Varaždin, Croatia', 46.2219, 16.3422, 'wishlist', random_date());
SELECT insert_marker(1, 'Cakovec', 'The capital of Međimurje County, located between Varaždin and the Hungarian border', 46.3803, 16.4378, 'visited', random_date());
SELECT insert_marker(2, 'Novakovec', 'A small village near Varaždin', 46.2700, 16.3590, 'wishlist', random_date());
SELECT insert_marker(3, 'Ivanec', 'A town situated to the east of Varaždin, Croatia', 46.2061, 16.3191, 'visited', random_date());

-- Optional: Retrieve the inserted data to confirm seeding
SELECT 
    id, 
    name, 
    LEFT(description, 20) AS description,  -- Truncates the description to 20 characters
    ST_X(geometry) AS lon,
    ST_Y(geometry) AS lat,
    visit_date,
    coord_type
FROM locations;
