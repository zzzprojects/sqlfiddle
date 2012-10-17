DROP table IF EXISTS db_types;

CREATE TABLE db_types (
    id integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
    full_name varchar(50),
    simple_name varchar(50),
    setup_script_template text,
    jdbc_class_name varchar(50),
    drop_script_template text,
    custom_jdbc_attributes varchar(100),
    batch_separator varchar(5),
    notes varchar(250),
    sample_fragment varchar(50),
    execution_plan_prefix varchar(500),
    execution_plan_suffix varchar(500),
    execution_plan_xslt text,
    context varchar(10),
    execution_plan_check varchar(300),
    is_latest_stable smallint DEFAULT 0
);

DROP table IF EXISTS hosts;

CREATE TABLE hosts (
    id integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
    db_type_id integer NOT NULL,
    jdbc_url_template varchar(150),
    cf_dsn varchar(50)
);

DROP table IF EXISTS queries;

CREATE TABLE queries (
    schema_def_id integer NOT NULL,
    sql text,
    md5 varchar(32),
    id integer NOT NULL,
    statement_separator varchar(5) DEFAULT ';',
    author_id integer,
    PRIMARY KEY(schema_def_id, id) 
);

DROP table IF EXISTS query_sets;

CREATE TABLE query_sets (
    id integer NOT NULL,
    query_id integer NOT NULL,
    schema_def_id integer NOT NULL,
    row_count integer,
    execution_time integer,
    succeeded smallint,
    sql text,
    execution_plan text,
    error_message text,
    columns_list varchar(500),
    PRIMARY KEY(id, schema_def_id, query_id)
);

DROP table IF EXISTS schema_defs;

CREATE TABLE schema_defs (
    id integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
    db_type_id integer NOT NULL,
    short_code varchar(32),
    last_used timestamp,
    ddl text,
    current_host_id integer,
    md5 varchar(32),
    statement_separator varchar(5) DEFAULT ';',
    owner_id integer,
    structure_json text
);

DROP table IF EXISTS user_fiddles;

CREATE TABLE user_fiddles (
    id integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id integer NOT NULL,
    schema_def_id integer NOT NULL,
    query_id integer,
    last_accessed timestamp DEFAULT current_date(),
    num_accesses integer DEFAULT 1,
    show_in_history smallint DEFAULT 1,
    favorite smallint DEFAULT 0
);

DROP table IF EXISTS users;

CREATE TABLE users (
    id integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
    identity varchar(1000) NOT NULL,
    openid_server varchar(1000) NOT NULL,
    auth_token varchar(35) NOT NULL,
    email varchar(1000),
    firstname varchar(200),
    lastname varchar(200)
);


