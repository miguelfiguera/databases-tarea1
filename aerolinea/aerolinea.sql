CREATE DATABASE aerolinea;

\c aerolinea

DROP TABLE IF EXISTS plane_details CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS flights CASCADE;
DROP TABLE IF EXISTS personel CASCADE;
DROP TABLE IF EXISTS passengers CASCADE;
DROP TABLE IF EXISTS planes CASCADE;

DROP TYPE IF EXISTS replenished_status CASCADE;
DROP TYPE IF EXISTS fuel_status CASCADE;
DROP TYPE IF EXISTS maintenance_status CASCADE;
DROP TYPE IF EXISTS personel_rol CASCADE;

CREATE TYPE replenished_status AS ENUM('pending', 'replenished', 'empty', 'used');
CREATE TYPE fuel_status AS ENUM ('refueled', 'pending');
CREATE TYPE maintenance_status AS ENUM('pending', 'performed');
CREATE TYPE personel_rol AS ENUM ('stewardess', 'copilot', 'pilot', 'steward');

CREATE TABLE planes (
	id SERIAL PRIMARY KEY,
	model VARCHAR(50) NOT NULL
);

CREATE TABLE passengers (
	id SERIAL PRIMARY KEY,
	dni VARCHAR(20) UNIQUE NOT NULL,
	name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(75) UNIQUE NOT NULL,
	dob DATE,
	active BOOLEAN DEFAULT true,
	phone VARCHAR(20) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_passengers_dni ON passengers(dni);
CREATE INDEX IF NOT EXISTS idx_passengers_last_name ON passengers(last_name, name);

CREATE TABLE personel (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	dni VARCHAR(20) UNIQUE NOT NULL,
	rol personel_rol NOT NULL,
	plane_id INTEGER REFERENCES planes(id),
	flight_hours INTEGER DEFAULT 0 NOT NULL,
	years_of_service INTEGER DEFAULT 0 NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_personel_dni ON personel(dni);
CREATE INDEX IF NOT EXISTS idx_personel_rol ON personel(rol);
CREATE INDEX IF NOT EXISTS idx_personel_plane_id ON personel(plane_id);

CREATE TABLE flights (
	id SERIAL PRIMARY KEY,
	city_of_arrival VARCHAR(50) NOT NULL,
	city_of_departure VARCHAR(50) NOT NULL,
	arrival_datetime TIMESTAMP WITH TIME ZONE,
	departure_datetime TIMESTAMP WITH TIME ZONE,
	plane_id INTEGER REFERENCES planes(id)
);
CREATE INDEX IF NOT EXISTS idx_flights_plane_id ON flights(plane_id);
CREATE INDEX IF NOT EXISTS idx_flights_departure_arrival_city ON flights(city_of_departure, city_of_arrival);
CREATE INDEX IF NOT EXISTS idx_flights_departure_datetime ON flights(departure_datetime);

CREATE TABLE tickets (
	id SERIAL PRIMARY KEY,
	passenger_id INTEGER NOT NULL REFERENCES passengers(id),
	flight_id INTEGER NOT NULL REFERENCES flights(id),
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	amount DECIMAL(8, 2),
	confirmed BOOLEAN DEFAULT false,
	seat_number VARCHAR(10),
	luggage_kg DECIMAL(4, 1) DEFAULT 0.0
);
CREATE INDEX IF NOT EXISTS idx_tickets_passenger_id ON tickets(passenger_id);
CREATE INDEX IF NOT EXISTS idx_tickets_flight_id ON tickets(flight_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_tickets_flight_seat ON tickets(flight_id, seat_number);

CREATE TABLE plane_details (
	id SERIAL PRIMARY KEY,
	plane_id INTEGER UNIQUE NOT NULL REFERENCES planes(id) ON DELETE CASCADE,
	captain_id INTEGER REFERENCES personel(id),
	copilot_id INTEGER REFERENCES personel(id),
	stewardess_one_id INTEGER REFERENCES personel(id),
	stewardess_two_id INTEGER REFERENCES personel(id),
	stewardess_three_id INTEGER REFERENCES personel(id),
	vip_capacity INTEGER NOT NULL CHECK (vip_capacity >= 0),
	commercial_capacity INTEGER NOT NULL CHECK (commercial_capacity >= 0),
	fuel_capacity_liters INTEGER NOT NULL CHECK (fuel_capacity_liters >= 0),
	extinguishers INTEGER NOT NULL CHECK (extinguishers >= 0),
	last_maintenance_date DATE,
	last_replenish_date DATE,
	last_refueled_date DATE,
	replenish_status replenished_status DEFAULT 'pending',
	fuel_level_status fuel_status DEFAULT 'pending',
	maintenance_status maintenance_status DEFAULT 'pending'
);
CREATE INDEX IF NOT EXISTS idx_plane_details_plane_id ON plane_details(plane_id);
CREATE INDEX IF NOT EXISTS idx_plane_details_captain_id ON plane_details(captain_id);
CREATE INDEX IF NOT EXISTS idx_plane_details_copilot_id ON plane_details(copilot_id);