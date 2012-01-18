--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: db_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE db_types (
    id integer NOT NULL,
    friendly_name character varying(50),
    jdbc_class_name character varying(50),
    jdbc_driver_name character varying(50),
    setup_script_template text,
    drop_script_template text
);


ALTER TABLE public.db_types OWNER TO postgres;

--
-- Name: db_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE db_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.db_types_id_seq OWNER TO postgres;

--
-- Name: db_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE db_types_id_seq OWNED BY db_types.id;


--
-- Name: db_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('db_types_id_seq', 1, true);


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE hosts (
    id integer NOT NULL,
    db_type_id integer NOT NULL,
    jdbc_url_template character varying(100),
    cf_dsn character varying(50)
);


ALTER TABLE public.hosts OWNER TO postgres;

--
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hosts_id_seq OWNER TO postgres;

--
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE hosts_id_seq OWNED BY hosts.id;


--
-- Name: hosts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('hosts_id_seq', 1, true);


--
-- Name: queries; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE queries (
    id integer NOT NULL,
    schema_def_id integer NOT NULL,
    sql text,
    md5 character varying(32)
);


ALTER TABLE public.queries OWNER TO postgres;

--
-- Name: schema_defs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE schema_defs (
    id integer NOT NULL,
    db_type_id integer NOT NULL,
    short_code character varying(32),
    md5 character varying(32),
    ddl text,
    last_used timestamp without time zone,
    current_host_id integer
);


ALTER TABLE public.schema_defs OWNER TO postgres;

--
-- Name: schema_defs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE schema_defs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schema_defs_id_seq OWNER TO postgres;

--
-- Name: schema_defs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE schema_defs_id_seq OWNED BY schema_defs.id;


--
-- Name: schema_defs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('schema_defs_id_seq', 1, true);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE db_types ALTER COLUMN id SET DEFAULT nextval('db_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE hosts ALTER COLUMN id SET DEFAULT nextval('hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE schema_defs ALTER COLUMN id SET DEFAULT nextval('schema_defs_id_seq'::regclass);


--
-- Data for Name: db_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY db_types (id, friendly_name, jdbc_driver_name, setup_script_template, jdbc_class_name, drop_script_template) FROM stdin;
1	PostgreSQL 9.1.1	PostgreSQL	CREATE USER user_#databaseName# PASSWORD '#databaseName#';\nCREATE DATABASE db_#databaseName# OWNER user_#databaseName# ENCODING 'UTF8';	org.postgresql.Driver	 DROP DATABASE db_#databaseName#;\n DROP USER user_#databaseName#;\n
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY hosts (id, db_type_id, jdbc_url_template, cf_dsn) FROM stdin;
1	1	jdbc:postgresql://127.0.0.1:5432/#databaseName#	sqlfiddle_pg1
\.


--
-- Data for Name: queries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY queries (schema_def_id, sql, md5, id) FROM stdin;
\.


--
-- Data for Name: schema_defs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY schema_defs (id, db_type_id, short_code, last_used, ddl, current_host_id, md5) FROM stdin;
\.


--
-- Name: db_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY db_types
    ADD CONSTRAINT db_types_pkey PRIMARY KEY (id);


--
-- Name: hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: queries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY queries
    ADD CONSTRAINT queries_pkey PRIMARY KEY (id, schema_def_id);


--
-- Name: schema_defs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY schema_defs
    ADD CONSTRAINT schema_defs_pkey PRIMARY KEY (id);


--
-- Name: query_md5s; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX query_md5s ON queries USING btree (md5, schema_def_id);


--
-- Name: schema_md5s; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX schema_md5s ON schema_defs USING btree (md5, db_type_id);


--
-- Name: schema_short_codes; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX schema_short_codes ON schema_defs USING btree (short_code, db_type_id);


--
-- Name: db_type_ref; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT db_type_ref FOREIGN KEY (db_type_id) REFERENCES db_types(id);


--
-- Name: db_type_ref; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY schema_defs
    ADD CONSTRAINT db_type_ref FOREIGN KEY (db_type_id) REFERENCES db_types(id);


--
-- Name: host_ref; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY schema_defs
    ADD CONSTRAINT host_ref FOREIGN KEY (current_host_id) REFERENCES hosts(id);


--
-- Name: schema_def_ref; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY queries
    ADD CONSTRAINT schema_def_ref FOREIGN KEY (schema_def_id) REFERENCES schema_defs(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

