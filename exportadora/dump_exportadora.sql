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
-- Name: order_status_enum; Type: TYPE; Schema: public; Owner: chepino
--

CREATE TYPE public.order_status_enum AS ENUM (
    'pending_confirmation',
    'confirmed',
    'processing',
    'ready_for_shipment',
    'partially_shipped',
    'shipped',
    'delivered',
    'completed',
    'cancelled',
    'on_hold'
);


ALTER TYPE public.order_status_enum OWNER TO chepino;

--
-- Name: payment_status_enum; Type: TYPE; Schema: public; Owner: chepino
--

CREATE TYPE public.payment_status_enum AS ENUM (
    'pending',
    'partially_paid',
    'paid',
    'overdue',
    'refunded'
);


ALTER TYPE public.payment_status_enum OWNER TO chepino;

--
-- Name: unit_of_measure_enum; Type: TYPE; Schema: public; Owner: chepino
--

CREATE TYPE public.unit_of_measure_enum AS ENUM (
    'kg',
    'g',
    'mg',
    'l',
    'ml',
    'pieza',
    'docena',
    'paquete',
    'caja',
    'bolsa',
    'botella',
    'metro',
    'cm',
    'm2',
    'm3',
    'lb',
    'oz',
    'gal',
    'par',
    'juego',
    'rollo'
);


ALTER TYPE public.unit_of_measure_enum OWNER TO chepino;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.clients (
    id integer NOT NULL,
    company_name character varying(255) NOT NULL,
    contact_person character varying(255),
    email character varying(255) NOT NULL,
    phone character varying(50),
    billing_address text,
    shipping_address text,
    country character varying(100) NOT NULL,
    tax_id character varying(100),
    credit_limit numeric(12,2) DEFAULT 0.00,
    payment_terms_agreed character varying(255)
);


ALTER TABLE public.clients OWNER TO chepino;

--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clients_id_seq OWNER TO chepino;

--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.clients_id_seq OWNED BY public.clients.id;


--
-- Name: commercial_invoices; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.commercial_invoices (
    id integer NOT NULL,
    invoice_number character varying(50) NOT NULL,
    sales_order_id integer,
    client_id integer NOT NULL,
    issue_date date DEFAULT CURRENT_DATE NOT NULL,
    due_date date,
    total_amount numeric(15,2) NOT NULL,
    currency character(3) DEFAULT 'USD'::bpchar NOT NULL,
    payment_status public.payment_status_enum DEFAULT 'pending'::public.payment_status_enum,
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.commercial_invoices OWNER TO chepino;

--
-- Name: commercial_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.commercial_invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commercial_invoices_id_seq OWNER TO chepino;

--
-- Name: commercial_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.commercial_invoices_id_seq OWNED BY public.commercial_invoices.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    sales_order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    discount_percentage numeric(5,2) DEFAULT 0.00,
    line_total numeric(15,2),
    CONSTRAINT order_items_discount_percentage_check CHECK (((discount_percentage >= (0)::numeric) AND (discount_percentage <= (100)::numeric))),
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT order_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE public.order_items OWNER TO chepino;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_items_id_seq OWNER TO chepino;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.products (
    id integer NOT NULL,
    sku character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    cost_price numeric(12,2) NOT NULL,
    unit_of_measure public.unit_of_measure_enum NOT NULL,
    supplier_id integer,
    country_of_origin character varying(100),
    hs_code character varying(50),
    weight_per_unit numeric(10,3),
    dimension_l_cm numeric(10,2),
    dimension_w_cm numeric(10,2),
    dimension_h_cm numeric(10,2),
    CONSTRAINT products_cost_price_check CHECK ((cost_price >= (0)::numeric))
);


ALTER TABLE public.products OWNER TO chepino;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO chepino;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: sales_orders; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.sales_orders (
    id integer NOT NULL,
    order_number character varying(50) NOT NULL,
    client_id integer NOT NULL,
    order_date date DEFAULT CURRENT_DATE NOT NULL,
    status public.order_status_enum DEFAULT 'pending_confirmation'::public.order_status_enum,
    currency character(3) DEFAULT 'USD'::bpchar NOT NULL,
    total_amount numeric(15,2) DEFAULT 0.00,
    expected_ship_date date,
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sales_orders OWNER TO chepino;

--
-- Name: sales_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.sales_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_orders_id_seq OWNER TO chepino;

--
-- Name: sales_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.sales_orders_id_seq OWNED BY public.sales_orders.id;


--
-- Name: shipments; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.shipments (
    id integer NOT NULL,
    shipment_number character varying(100),
    sales_order_id integer,
    ship_date date,
    carrier_name character varying(255),
    tracking_number character varying(255),
    port_of_loading character varying(255),
    port_of_discharge character varying(255),
    estimated_arrival_date date,
    actual_arrival_date date,
    status character varying(100) DEFAULT 'pending_shipment'::character varying,
    freight_cost numeric(12,2),
    insurance_cost numeric(12,2),
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.shipments OWNER TO chepino;

--
-- Name: shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.shipments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shipments_id_seq OWNER TO chepino;

--
-- Name: shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.shipments_id_seq OWNED BY public.shipments.id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: chepino
--

CREATE TABLE public.suppliers (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    contact_person character varying(255),
    email character varying(255),
    phone character varying(50),
    address text,
    payment_terms character varying(255)
);


ALTER TABLE public.suppliers OWNER TO chepino;

--
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: chepino
--

CREATE SEQUENCE public.suppliers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.suppliers_id_seq OWNER TO chepino;

--
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chepino
--

ALTER SEQUENCE public.suppliers_id_seq OWNED BY public.suppliers.id;


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_seq'::regclass);


--
-- Name: commercial_invoices id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.commercial_invoices ALTER COLUMN id SET DEFAULT nextval('public.commercial_invoices_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: sales_orders id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.sales_orders ALTER COLUMN id SET DEFAULT nextval('public.sales_orders_id_seq'::regclass);


--
-- Name: shipments id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.shipments ALTER COLUMN id SET DEFAULT nextval('public.shipments_id_seq'::regclass);


--
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.clients (id, company_name, contact_person, email, phone, billing_address, shipping_address, country, tax_id, credit_limit, payment_terms_agreed) FROM stdin;
\.


--
-- Data for Name: commercial_invoices; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.commercial_invoices (id, invoice_number, sales_order_id, client_id, issue_date, due_date, total_amount, currency, payment_status, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.order_items (id, sales_order_id, product_id, quantity, unit_price, discount_percentage, line_total) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.products (id, sku, name, description, cost_price, unit_of_measure, supplier_id, country_of_origin, hs_code, weight_per_unit, dimension_l_cm, dimension_w_cm, dimension_h_cm) FROM stdin;
\.


--
-- Data for Name: sales_orders; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.sales_orders (id, order_number, client_id, order_date, status, currency, total_amount, expected_ship_date, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: shipments; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.shipments (id, shipment_number, sales_order_id, ship_date, carrier_name, tracking_number, port_of_loading, port_of_discharge, estimated_arrival_date, actual_arrival_date, status, freight_cost, insurance_cost, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: chepino
--

COPY public.suppliers (id, name, contact_person, email, phone, address, payment_terms) FROM stdin;
\.


--
-- Name: clients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.clients_id_seq', 1, false);


--
-- Name: commercial_invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.commercial_invoices_id_seq', 1, false);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.order_items_id_seq', 1, false);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.products_id_seq', 1, false);


--
-- Name: sales_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.sales_orders_id_seq', 1, false);


--
-- Name: shipments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.shipments_id_seq', 1, false);


--
-- Name: suppliers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chepino
--

SELECT pg_catalog.setval('public.suppliers_id_seq', 1, false);


--
-- Name: clients clients_email_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_email_key UNIQUE (email);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: commercial_invoices commercial_invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.commercial_invoices
    ADD CONSTRAINT commercial_invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: commercial_invoices commercial_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.commercial_invoices
    ADD CONSTRAINT commercial_invoices_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: sales_orders sales_orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_order_number_key UNIQUE (order_number);


--
-- Name: sales_orders sales_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_pkey PRIMARY KEY (id);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);


--
-- Name: shipments shipments_shipment_number_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_shipment_number_key UNIQUE (shipment_number);


--
-- Name: suppliers suppliers_email_key; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_email_key UNIQUE (email);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: idx_clients_company_name; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_clients_company_name ON public.clients USING btree (company_name);


--
-- Name: idx_clients_country; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_clients_country ON public.clients USING btree (country);


--
-- Name: idx_commercial_invoices_client_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_commercial_invoices_client_id ON public.commercial_invoices USING btree (client_id);


--
-- Name: idx_commercial_invoices_issue_date; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_commercial_invoices_issue_date ON public.commercial_invoices USING btree (issue_date);


--
-- Name: idx_commercial_invoices_payment_status; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_commercial_invoices_payment_status ON public.commercial_invoices USING btree (payment_status);


--
-- Name: idx_commercial_invoices_sales_order_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_commercial_invoices_sales_order_id ON public.commercial_invoices USING btree (sales_order_id);


--
-- Name: idx_order_items_product_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_order_items_product_id ON public.order_items USING btree (product_id);


--
-- Name: idx_order_items_sales_order_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_order_items_sales_order_id ON public.order_items USING btree (sales_order_id);


--
-- Name: idx_products_name; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_products_name ON public.products USING btree (name);


--
-- Name: idx_products_sku; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_products_sku ON public.products USING btree (sku);


--
-- Name: idx_products_supplier_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_products_supplier_id ON public.products USING btree (supplier_id);


--
-- Name: idx_sales_orders_client_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_sales_orders_client_id ON public.sales_orders USING btree (client_id);


--
-- Name: idx_sales_orders_order_date; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_sales_orders_order_date ON public.sales_orders USING btree (order_date);


--
-- Name: idx_sales_orders_status; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_sales_orders_status ON public.sales_orders USING btree (status);


--
-- Name: idx_shipments_sales_order_id; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_shipments_sales_order_id ON public.shipments USING btree (sales_order_id);


--
-- Name: idx_shipments_ship_date; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_shipments_ship_date ON public.shipments USING btree (ship_date);


--
-- Name: idx_shipments_tracking_number; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_shipments_tracking_number ON public.shipments USING btree (tracking_number);


--
-- Name: idx_suppliers_email; Type: INDEX; Schema: public; Owner: chepino
--

CREATE INDEX idx_suppliers_email ON public.suppliers USING btree (email);


--
-- Name: commercial_invoices commercial_invoices_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.commercial_invoices
    ADD CONSTRAINT commercial_invoices_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE RESTRICT;


--
-- Name: commercial_invoices commercial_invoices_sales_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.commercial_invoices
    ADD CONSTRAINT commercial_invoices_sales_order_id_fkey FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id) ON DELETE SET NULL;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: order_items order_items_sales_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_sales_order_id_fkey FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id) ON DELETE CASCADE;


--
-- Name: products products_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: sales_orders sales_orders_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE RESTRICT;


--
-- Name: shipments shipments_sales_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chepino
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_sales_order_id_fkey FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

