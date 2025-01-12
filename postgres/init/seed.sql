-- Updated seeding script for populating the database with sample data linked to users and supporting enum and updated schema

-- Helper function to generate random date between 2014 and 2025
CREATE OR REPLACE FUNCTION random_date() RETURNS DATE AS $$
BEGIN
    RETURN CURRENT_DATE - (FLOOR(RANDOM() * (365 * (2025 - 2014)))) * INTERVAL '1 day';
END;
$$ LANGUAGE plpgsql;

-- Create dummy users to associate with locations
DO $$ BEGIN
PERFORM "register_user"('user1', 'password1');
PERFORM "register_user"('user2', 'password2');
PERFORM "register_user"('user3', 'password3');
END $$;

-- Zagreb Locations
DO $$ BEGIN
PERFORM "insert_marker"(2, 'Ban Jelačić Square', 'Main square in the center of Zagreb, Croatia', 45.8131, 15.978, 'visited', random_date());
PERFORM "insert_marker"(1, 'Zagreb Cathedral', 'The cathedral of the Archdiocese of Zagreb, Croatia', 45.8138, 15.9786, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Maksimir Park', 'The largest park in Zagreb, Croatia', 45.8077, 16.0249, 'visited', random_date());
PERFORM "insert_marker"(2, 'Museum of Broken Relationships', 'Museum dedicated to failed love relationships, located in Zagreb', 45.8133, 15.9761, 'wishlist', random_date());
PERFORM "insert_marker"(1, 'Upper Town (Gornji Grad)', 'Historic part of Zagreb with cobblestone streets and medieval architecture', 45.8139, 15.9775, 'visited', random_date());
PERFORM "insert_marker"(3, 'Tkalčićeva Street', 'Famous street in Zagreb with numerous bars and restaurants', 45.8134, 15.9797, 'wishlist', random_date());
PERFORM "insert_marker"(2, 'Zrinjevac Park', 'A beautiful park in the heart of Zagreb, Croatia', 45.8130, 15.9811, 'visited', random_date());
PERFORM "insert_marker"(1, 'Jarun Lake', 'A large lake in Zagreb popular for sports and recreation', 45.7876, 15.9852, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'King Tomislav Square', 'A public square in Zagreb dedicated to the first Croatian king', 45.8121, 15.9765, 'visited', random_date());
PERFORM "insert_marker"(2, 'Lotrščak Tower', 'A medieval tower in Zagreb, known for the daily cannon shot', 45.8137, 15.9768, 'wishlist', random_date());
END $$;

-- Varaždin Locations
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Varaždin Old Town', 'A medieval fortress and the historic center of Varaždin, Croatia', 46.3056, 16.3372, 'visited', random_date());
PERFORM "insert_marker"(2, 'Varaždin Castle', 'A historic castle located in the center of Varaždin', 46.3066, 16.3394, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Trg Kralja Tomislava', 'A central square in Varaždin', 46.3052, 16.3379, 'visited', random_date());
PERFORM "insert_marker"(1, 'Varaždin City Museum', 'Museum dedicated to the history and culture of Varaždin, Croatia', 46.3059, 16.3390, 'wishlist', random_date());
PERFORM "insert_marker"(2, 'St. Nicholas’ Church', 'A historic church located in the city center of Varaždin', 46.3058, 16.3382, 'visited', random_date());
PERFORM "insert_marker"(3, 'Civic Centre Varaždin', 'A major public space in the city of Varaždin', 46.3051, 16.3373, 'wishlist', random_date());
PERFORM "insert_marker"(1, 'Park Nezavisnosti', 'A green park area in the city center of Varaždin', 46.3048, 16.3377, 'visited', random_date());
PERFORM "insert_marker"(2, 'Drava River Bank', 'The scenic river bank area in Varaždin, Croatia', 46.3092, 16.3380, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Varaždin Cemetery', 'A large historical cemetery located on the outskirts of Varaždin', 46.3113, 16.3486, 'visited', random_date());
PERFORM "insert_marker"(1, 'St. George’s Church', 'An important church located in the city center of Varaždin', 46.3060, 16.3367, 'wishlist', random_date());
END $$;

-- Additional Varaždin Locations
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Varaždin Town Hall', 'A historical building located in the heart of Varaždin with a beautiful clock tower', 46.3036, 16.3402, 'visited', random_date());
PERFORM "insert_marker"(2, 'Varaždin Baroque Ensemble', 'A group of historical buildings showcasing the baroque architectural style of Varaždin', 46.3054, 16.3386, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Varaždin Synagogue', 'The historical synagogue of Varaždin, an important cultural landmark', 46.3063, 16.3378, 'visited', random_date());
PERFORM "insert_marker"(1, 'Varaždin Cathedral', 'The Cathedral of St. Nicholas, a prominent baroque church in Varaždin', 46.3049, 16.3381, 'wishlist', random_date());
PERFORM "insert_marker"(2, 'Varaždin Train Station', 'A railway station connecting Varaždin to other major Croatian cities', 46.3019, 16.3418, 'visited', random_date());
PERFORM "insert_marker"(3, 'Varaždin City Park', 'A spacious park ideal for relaxation and outdoor activities', 46.3053, 16.3407, 'wishlist', random_date());
PERFORM "insert_marker"(1, 'Varaždin Water Tower', 'A historic water tower providing panoramic views of the city', 46.3069, 16.3412, 'visited', random_date());
PERFORM "insert_marker"(2, 'Varaždin Library', 'A modern library located near the town square, offering a wide range of books and digital media', 46.3045, 16.3395, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Varaždin Bridge', 'A bridge connecting the two parts of the city, with beautiful views of the Drava River', 46.3075, 16.3390, 'visited', random_date());
PERFORM "insert_marker"(1, 'Varaždin Observation Deck', 'A lookout point with a panoramic view of the city and surrounding countryside', 46.3072, 16.3365, 'wishlist', random_date());
PERFORM "insert_marker"(2, 'Varaždin Theater', 'A historic theater showcasing local performances and international plays', 46.3032, 16.3400, 'visited', random_date());
PERFORM "insert_marker"(3, 'Varaždin Aquatic Center', 'A large sports complex with swimming pools and recreational facilities', 46.3080, 16.3358, 'wishlist', random_date());
PERFORM "insert_marker"(1, 'Varaždin Outdoor Market', 'A popular market where locals sell fresh produce, flowers, and handmade goods', 46.3041, 16.3384, 'visited', random_date());
PERFORM "insert_marker"(2, 'Varaždin Historical Society', 'A museum dedicated to the history of Varaždin, its people, and their culture', 46.3030, 16.3364, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Varaždin Amphitheater', 'An ancient Roman amphitheater that hosts various events and concerts', 46.3090, 16.3440, 'visited', random_date());
PERFORM "insert_marker"(1, 'Varaždin Golf Course', 'A scenic golf course located just outside the city', 46.3070, 16.3405, 'wishlist', random_date());
PERFORM "insert_marker"(2, 'Varaždin Brewery', 'A historical brewery known for producing some of the best local beer in Varaždin', 46.3050, 16.3422, 'visited', random_date());
PERFORM "insert_marker"(3, 'Varaždin Zoo', 'A small zoo that features native Croatian wildlife as well as exotic animals', 46.3100, 16.3450, 'wishlist', random_date());
PERFORM "insert_marker"(1, 'Varaždin Botanical Garden', 'A beautiful botanical garden showcasing a variety of plants and flowers', 46.3057, 16.3360, 'visited', random_date());
PERFORM "insert_marker"(2, 'Varaždin City Hall', 'A historical city hall, now a cultural center and event space', 46.3042, 16.3405, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Varaždin Nature Reserve', 'A nature reserve located just outside the city, ideal for hiking and bird watching', 46.3115, 16.3510, 'visited', random_date());
END $$;

-- New York City, USA
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Statue of Liberty', 'Iconic symbol of freedom located on Liberty Island', 40.6892, -74.0445, 'visited', random_date());
PERFORM "insert_marker"(2, 'Central Park', 'A large public park in Manhattan offering various recreational activities', 40.7851, -73.9683, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Empire State Building', 'Famous skyscraper offering panoramic views of the city', 40.748817, -73.985428, 'visited', random_date());
END $$;

-- Los Angeles, USA
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Hollywood Sign', 'Famous landmark in the Hollywood Hills overlooking Los Angeles', 34.1341, -118.3215, 'wishlist', random_date());
PERFORM "insert_marker"(2, 'Santa Monica Pier', 'Popular amusement pier located in Santa Monica, California', 34.0226, -118.4957, 'visited', random_date());
PERFORM "insert_marker"(3, 'Griffith Observatory', 'Observatory offering amazing views of Los Angeles and the Hollywood sign', 34.1184, -118.3004, 'visited', random_date());
END $$;

-- Chicago, USA
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Millennium Park', 'Public park in the heart of downtown Chicago featuring the famous Cloud Gate sculpture', 41.8826, -87.6233, 'wishlist', random_date());
PERFORM "insert_marker"(2, 'Willis Tower', 'Famous skyscraper with an observation deck offering stunning views of the city', 41.8789, -87.6359, 'visited', random_date());
PERFORM "insert_marker"(3, 'Navy Pier', 'Popular tourist destination featuring rides, restaurants, and shops', 41.8916, -87.6095, 'visited', random_date());
END $$;

-- London, UK
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Big Ben', 'Famous clock tower located at the north end of the Palace of Westminster', 51.5007, -0.1246, 'visited', random_date());
PERFORM "insert_marker"(2, 'The British Museum', 'A world-famous museum showcasing artifacts from ancient civilizations', 51.5194, -0.1270, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'London Eye', 'Giant Ferris wheel offering stunning views of the city', 51.5033, -0.1196, 'visited', random_date());
END $$;

-- Paris, France
DO $$ BEGIN
PERFORM "insert_marker"(2, 'Louvre Museum', 'World-renowned museum housing famous art like the Mona Lisa', 48.8606, 2.3376, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Notre-Dame Cathedral', 'Famous Gothic cathedral located on the Île de la Cité in Paris', 48.8529, 2.3500, 'visited', random_date());
END $$;

-- Rome, Italy
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Colosseum', 'Ancient Roman gladiatorial arena located in the center of Rome', 41.8902, 12.4922, 'visited', random_date());
PERFORM "insert_marker"(2, 'Vatican City', 'Home of the Pope and a UNESCO World Heritage site', 41.9029, 12.4534, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Pantheon', 'Ancient Roman temple known for its magnificent dome', 41.8986, 12.4769, 'visited', random_date());
END $$;

-- Venice, Italy
DO $$ BEGIN
PERFORM "insert_marker"(1, 'St. Mark\s Basilica', 'Iconic cathedral in the main square of Venice', 45.4340, 12.3386, 'visited', random_date());
PERFORM "insert_marker"(2, 'Rialto Bridge', 'Famous bridge spanning the Grand Canal in Venice', 45.4390, 12.3347, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Doge\s Palace', 'Former palace and seat of the government in Venice', 45.4348, 12.3347, 'visited', random_date());
END $$;

-- Barcelona, Spain
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Sagrada Familia', 'Famous basilica designed by Antoni Gaudí', 41.4036, 2.1744, 'visited', random_date());
PERFORM "insert_marker"(2, 'Park Güell', 'Public park designed by Antoni Gaudí featuring colorful mosaics', 41.4145, 2.1527, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'La Rambla', 'Famous tree-lined street in central Barcelona', 41.3809, 2.1923, 'visited', random_date());
END $$;

-- Madrid, Spain
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Royal Palace of Madrid', 'Official residence of the Spanish Royal Family', 40.4179, -3.7143, 'visited', random_date());
PERFORM "insert_marker"(2, 'Prado Museum', 'Famous museum in Madrid housing one of the finest collections of European art', 40.4138, -3.6921, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Puerta del Sol', 'Central square in Madrid known for the clock tower and New Years Eve tradition', 40.4168, -3.7038, 'visited', random_date());
END $$;

-- Tokyo, Japan
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Tokyo Tower', 'Iconic red and white tower providing panoramic views of Tokyo', 35.6586, 139.7454, 'visited', random_date());
PERFORM "insert_marker"(2, 'Senso-ji Temple', 'The oldest and most significant Buddhist temple in Tokyo', 35.7148, 139.7967, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Shibuya Crossing', 'Famous pedestrian scramble and symbol of Tokyo’s bustling city life', 35.6580, 139.7013, 'visited', random_date());
END $$;

-- Kyoto, Japan
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Kinkaku-ji', 'Golden Pavilion, a Zen Buddhist temple and UNESCO World Heritage Site', 35.0394, 135.7292, 'visited', random_date());
PERFORM "insert_marker"(2, 'Fushimi Inari-taisha', 'Famous shrine known for its thousands of vermilion torii gates', 35.0390, 135.7765, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Arashiyama Bamboo Grove', 'A scenic bamboo forest and popular tourist attraction', 35.0094, 135.6758, 'visited', random_date());
END $$;

-- Sydney, Australia
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Sydney Opera House', 'Iconic performing arts venue with a distinctive sail-like design', -33.8568, 151.2153, 'visited', random_date());
PERFORM "insert_marker"(2, 'Sydney Harbour Bridge', 'Famous bridge linking the central business district to the North Shore', -33.8486, 151.2108, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Bondi Beach', 'Popular beach known for surfing and its coastal walk', -33.8908, 151.2743, 'visited', random_date());
END $$;

-- Melbourne, Australia
DO $$ BEGIN
PERFORM "insert_marker"(1, 'Royal Botanic Gardens', 'Scenic gardens offering walking paths and waterfront views', -37.8303, 144.9741, 'visited', random_date());
PERFORM "insert_marker"(2, 'Federation Square', 'Iconic public space with cultural attractions and restaurants', -37.8186, 144.9670, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Queen Victoria Market', 'Large open-air market with food, clothing, and souvenirs', -37.8075, 144.9577, 'visited', random_date());
END $$;

-- Additional Locations in between Zagreb and Varaždin (within ~50km radius)
DO $$ BEGIN
PERFORM "insert_marker"(2, 'Ludbreg', 'A town located between Zagreb and Varaždin, known for its religious significance', 46.2850, 16.4167, 'visited', random_date());
PERFORM "insert_marker"(3, 'Breznica', 'A small village located south of Varaždin, Croatia', 46.2219, 16.3422, 'wishlist', random_date());
PERFORM "insert_marker"(1, 'Cakovec', 'The capital of Međimurje County, located between Varaždin and the Hungarian border', 46.3803, 16.4378, 'visited', random_date());
PERFORM "insert_marker"(2, 'Novakovec', 'A small village near Varaždin', 46.2700, 16.3590, 'wishlist', random_date());
PERFORM "insert_marker"(3, 'Ivanec', 'A town situated to the east of Varaždin, Croatia', 46.2061, 16.3191, 'visited', random_date());
END $$;

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
