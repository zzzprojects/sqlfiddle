--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: db_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE db_types (
    id integer NOT NULL,
    full_name character varying(50),
    simple_name character varying(50),
    setup_script_template text,
    jdbc_class_name character varying(50),
    drop_script_template text,
    custom_jdbc_attributes character varying(100),
    batch_separator character varying(5),
    notes character varying(250),
    sample_fragment character varying(50),
    execution_plan_prefix character varying(500),
    execution_plan_suffix character varying(500),
    execution_plan_xslt text,
    context character varying(10)
);


ALTER TABLE public.db_types OWNER TO postgres;

--
-- Name: db_types2_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE db_types2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.db_types2_id_seq OWNER TO postgres;

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
-- Name: hosts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE hosts (
    id integer NOT NULL,
    db_type_id integer NOT NULL,
    jdbc_url_template character varying(150),
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
-- Name: queries; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE queries (
    schema_def_id integer NOT NULL,
    sql text,
    md5 character varying(32),
    id integer NOT NULL
);


ALTER TABLE public.queries OWNER TO postgres;

--
-- Name: schema_defs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE schema_defs (
    id integer NOT NULL,
    db_type_id integer NOT NULL,
    short_code character varying(32),
    last_used timestamp without time zone,
    ddl text,
    current_host_id integer,
    md5 character varying(32)
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
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY db_types ALTER COLUMN id SET DEFAULT nextval('db_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hosts ALTER COLUMN id SET DEFAULT nextval('hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY schema_defs ALTER COLUMN id SET DEFAULT nextval('schema_defs_id_seq'::regclass);


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

