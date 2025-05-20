--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.2)
-- Dumped by pg_dump version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fuel_status; Type: TYPE; Schema: public; Owner: chepino
--

CREATE TYPE public.fuel_status AS ENUM (
    'refueled',
    'pending'
);


ALTER TYPE public.fuel_status OWNER TO chepino;

--
-- Name: maintenance_status; Type: TYPE; Schema: public; Owner: chepino
--

CREATE TYPE public.maintenance_status AS ENUM (
    'pending',
    'performed'
);


ALTER TYPE public.maintenance_status OWNER TO chepino;

--
-- Name: personel_rol; Type: TYPE; Schema: public; Owner: chepino
--

CREATE TYPE public.personel_rol AS ENUM (
    'stewardess',
    'copilot',
    'pilot',
    'steward'
);


ALTER TYPE public.personel_rol OWNER TO chepino;

--
-- Name: replenished_status; Type: TYPE; Schema: public; Owner: chepino
--

CREATE TYPE public.replenished_status AS ENUM (
    'pending',
    'replenished',
    'empty',
    'used'
);


ALTER TYPE public.replenished_status OWNER TO chepino;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: flights; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.flights (
    id integer NOT NULL,
    city_of_arrival character varying(50) NOT NULL,
    city_of_departure character varying(50) NOT NULL,
    arrival_datetime timestamp with time zone,
    departure_datetime timestamp with time zone,
    plane_id integer
);


ALTER TABLE public.flights OWNER TO chepino;

--
-- Name: flights_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.flights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flights_id_seq OWNER TO chepino;

--
-- Name: flights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.flights_id_seq OWNED BY public.flights.id;


--
-- Name: passengers; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.passengers (
    id integer NOT NULL,
    dni character varying(20) NOT NULL,
    name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(75) NOT NULL,
    dob date,
    active boolean DEFAULT true,
    phone character varying(20) NOT NULL
);


ALTER TABLE public.passengers OWNER TO chepino;

--
-- Name: passengers_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.passengers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.passengers_id_seq OWNER TO chepino;

--
-- Name: passengers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.passengers_id_seq OWNED BY public.passengers.id;


--
-- Name: personel; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.personel (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    dni character varying(20) NOT NULL,
    rol public.personel_rol NOT NULL,
    plane_id integer,
    flight_hours integer DEFAULT 0 NOT NULL,
    years_of_service integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.personel OWNER TO chepino;

--
-- Name: personel_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.personel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personel_id_seq OWNER TO chepino;

--
-- Name: personel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.personel_id_seq OWNED BY public.personel.id;


--
-- Name: plane_details; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.plane_details (
    id integer NOT NULL,
    plane_id integer NOT NULL,
    captain_id integer,
    copilot_id integer,
    stewardess_one_id integer,
    stewardess_two_id integer,
    stewardess_three_id integer,
    vip_capacity integer NOT NULL,
    commercial_capacity integer NOT NULL,
    fuel_capacity_liters integer NOT NULL,
    extinguishers integer NOT NULL,
    last_maintenance_date date,
    last_replenish_date date,
    last_refueled_date date,
    replenish_status public.replenished_status DEFAULT 'pending'::public.replenished_status,
    fuel_level_status public.fuel_status DEFAULT 'pending'::public.fuel_status,
    maintenance_status public.maintenance_status DEFAULT 'pending'::public.maintenance_status,
    CONSTRAINT plane_details_commercial_capacity_check CHECK ((commercial_capacity >= 0)),
    CONSTRAINT plane_details_extinguishers_check CHECK ((extinguishers >= 0)),
    CONSTRAINT plane_details_fuel_capacity_liters_check CHECK ((fuel_capacity_liters >= 0)),
    CONSTRAINT plane_details_vip_capacity_check CHECK ((vip_capacity >= 0))
);


ALTER TABLE public.plane_details OWNER TO chepino;

--
-- Name: plane_details_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.plane_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.plane_details_id_seq OWNER TO chepino;

--
-- Name: plane_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.plane_details_id_seq OWNED BY public.plane_details.id;


--
-- Name: planes; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.planes (
    id integer NOT NULL,
    model character varying(50) NOT NULL
);


ALTER TABLE public.planes OWNER TO chepino;

--
-- Name: planes_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.planes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.planes_id_seq OWNER TO chepino;

--
-- Name: planes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.planes_id_seq OWNED BY public.planes.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    passenger_id integer NOT NULL,
    flight_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    amount numeric(8,2),
    confirmed boolean DEFAULT false,
    seat_number character varying(10),
    luggage_kg numeric(4,1) DEFAULT 0.0
);


ALTER TABLE public.tickets OWNER TO chepino;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_id_seq OWNER TO chepino;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: flights id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.flights ALTER COLUMN id SET DEFAULT nextval('public.flights_id_seq'::regclass);


--
-- Name: passengers id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.passengers ALTER COLUMN id SET DEFAULT nextval('public.passengers_id_seq'::regclass);


--
-- Name: personel id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.personel ALTER COLUMN id SET DEFAULT nextval('public.personel_id_seq'::regclass);


--
-- Name: plane_details id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.plane_details ALTER COLUMN id SET DEFAULT nextval('public.plane_details_id_seq'::regclass);


--
-- Name: planes id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.planes ALTER COLUMN id SET DEFAULT nextval('public.planes_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Data for Name: flights; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.flights (id, city_of_arrival, city_of_departure, arrival_datetime, departure_datetime, plane_id) FROM stdin;
\.


--
-- Data for Name: passengers; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.passengers (id, dni, name, last_name, email, dob, active, phone) FROM stdin;
\.


--
-- Data for Name: personel; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.personel (id, name, last_name, dni, rol, plane_id, flight_hours, years_of_service) FROM stdin;
\.


--
-- Data for Name: plane_details; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.plane_details (id, plane_id, captain_id, copilot_id, stewardess_one_id, stewardess_two_id, stewardess_three_id, vip_capacity, commercial_capacity, fuel_capacity_liters, extinguishers, last_maintenance_date, last_replenish_date, last_refueled_date, replenish_status, fuel_level_status, maintenance_status) FROM stdin;
\.


--
-- Data for Name: planes; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.planes (id, model) FROM stdin;
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.tickets (id, passenger_id, flight_id, created_at, amount, confirmed, seat_number, luggage_kg) FROM stdin;
\.


--
-- Name: flights_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.flights_id_seq', 1, false);


--
-- Name: passengers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.passengers_id_seq', 1, false);


--
-- Name: personel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.personel_id_seq', 1, false);


--
-- Name: plane_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.plane_details_id_seq', 1, false);


--
-- Name: planes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.planes_id_seq', 1, false);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.tickets_id_seq', 1, false);


--
-- Name: flights flights_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (id);


--
-- Name: passengers passengers_dni_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT passengers_dni_key UNIQUE (dni);


--
-- Name: passengers passengers_email_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT passengers_email_key UNIQUE (email);


--
-- Name: passengers passengers_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT passengers_pkey PRIMARY KEY (id);


--
-- Name: personel personel_dni_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT personel_dni_key UNIQUE (dni);


--
-- Name: personel personel_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT personel_pkey PRIMARY KEY (id);


--
-- Name: plane_details plane_details_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.plane_details
    ADD CONSTRAINT plane_details_pkey PRIMARY KEY (id);


--
-- Name: plane_details plane_details_plane_id_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.plane_details
    ADD CONSTRAINT plane_details_plane_id_key UNIQUE (plane_id);


--
-- Name: planes planes_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.planes
    ADD CONSTRAINT planes_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: idx_flights_departure_arrival_city; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_flights_departure_arrival_city ON public.flights USING btree (city_of_departure, city_of_arrival);


--
-- Name: idx_flights_departure_datetime; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_flights_departure_datetime ON public.flights USING btree (departure_datetime);


--
-- Name: idx_flights_plane_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_flights_plane_id ON public.flights USING btree (plane_id);


--
-- Name: idx_passengers_dni; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_passengers_dni ON public.passengers USING btree (dni);


--
-- Name: idx_passengers_last_name; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_passengers_last_name ON public.passengers USING btree (last_name, name);


--
-- Name: idx_personel_dni; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_personel_dni ON public.personel USING btree (dni);


--
-- Name: idx_personel_plane_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_personel_plane_id ON public.personel USING btree (plane_id);


--
-- Name: idx_personel_rol; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_personel_rol ON public.personel USING btree (rol);


--
-- Name: idx_plane_details_captain_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_plane_details_captain_id ON public.plane_details USING btree (captain_id);


--
-- Name: idx_plane_details_copilot_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_plane_details_copilot_id ON public.plane_details USING btree (copilot_id);


--
-- Name: idx_plane_details_plane_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_plane_details_plane_id ON public.plane_details USING btree (plane_id);


--
-- Name: idx_tickets_flight_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_tickets_flight_id ON public.tickets USING btree (flight_id);


--
-- Name: idx_tickets_flight_seat; Type: INDEX; Schema: public; Owner: chepino
--

CREATE UNIQUE INDEX idx_tickets_flight_seat ON public.tickets USING btree (flight_id, seat_number);


--
-- Name: idx_tickets_passenger_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_tickets_passenger_id ON public.tickets USING btree (passenger_id);


--
-- Name: flights flights_plane_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT flights_plane_id_fkey FOREIGN KEY (plane_id) REFERENCES public.planes(id);


--
-- Name: personel personel_plane_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT personel_plane_id_fkey FOREIGN KEY (plane_id) REFERENCES public.planes(id);


--
-- Name: plane_details plane_details_captain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.plane_details
    ADD CONSTRAINT plane_details_captain_id_fkey FOREIGN KEY (captain_id) REFERENCES public.personel(id);


--
-- Name: plane_details plane_details_copilot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.plane_details
    ADD CONSTRAINT plane_details_copilot_id_fkey FOREIGN KEY (copilot_id) REFERENCES public.personel(id);


--
-- Name: plane_details plane_details_plane_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.plane_details
    ADD CONSTRAINT plane_details_plane_id_fkey FOREIGN KEY (plane_id) REFERENCES public.planes(id) ON DELETE CASCADE;


--
-- Name: plane_details plane_details_stewardess_one_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.plane_details
    ADD CONSTRAINT plane_details_stewardess_one_id_fkey FOREIGN KEY (stewardess_one_id) REFERENCES public.personel(id);


--
-- Name: plane_details plane_details_stewardess_three_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.plane_details
    ADD CONSTRAINT plane_details_stewardess_three_id_fkey FOREIGN KEY (stewardess_three_id) REFERENCES public.personel(id);


--
-- Name: plane_details plane_details_stewardess_two_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.plane_details
    ADD CONSTRAINT plane_details_stewardess_two_id_fkey FOREIGN KEY (stewardess_two_id) REFERENCES public.personel(id);


--
-- Name: tickets tickets_flight_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES public.flights(id);


--
-- Name: tickets tickets_passenger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_passenger_id_fkey FOREIGN KEY (passenger_id) REFERENCES public.passengers(id);


--
-- PostgreSQL database dump complete
--

