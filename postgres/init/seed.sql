-- Seeding file for populating the database with sample locations

-- Inserting sample markers using the insert_marker function
SELECT insert_marker('Eiffel Tower', 'A wrought-iron lattice tower in Paris, France', 48.8584, 2.2945);
SELECT insert_marker('Great Wall of China', 'An ancient series of walls and fortifications located in northern China', 40.4319, 116.5704);
SELECT insert_marker('Statue of Liberty', 'A colossal neoclassical sculpture on Liberty Island in New York City, USA', 40.6892, -74.0445);
SELECT insert_marker('Machu Picchu', 'An Incan citadel located in the Eastern Andes in Peru', -13.1631, -72.5450);
SELECT insert_marker('Pyramids of Giza', 'Ancient pyramid structures located in Giza, Egypt', 29.9792, 31.1342);
SELECT insert_marker('Sydney Opera House', 'A multi-venue performing arts center in Sydney, Australia', -33.8568, 151.2153);
SELECT insert_marker('Colosseum', 'An ancient amphitheater located in the center of Rome, Italy', 41.8902, 12.4922);
SELECT insert_marker('Taj Mahal', 'A white marble mausoleum located in Agra, India', 27.1751, 78.0421);
SELECT insert_marker('Christ the Redeemer', 'A large statue of Jesus Christ in Rio de Janeiro, Brazil', -22.9519, -43.2105);
SELECT insert_marker('Mount Fuji', 'An active stratovolcano located in Japan', 35.3606, 138.7274);

-- Optional: Retrieve the inserted data to confirm seeding
SELECT * FROM lokacije;
