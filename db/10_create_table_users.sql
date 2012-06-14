CREATE TABLE users
(
	id serial primary key,
	identity varchar(1000) not null,
	openid_server varchar(1000) not null,
	auth_token varchar(35) not null,
	email varchar(1000),
	firstname varchar(200),
	lastname varchar(200)
);

CREATE UNIQUE INDEX user_identities ON users USING btree (identity);
