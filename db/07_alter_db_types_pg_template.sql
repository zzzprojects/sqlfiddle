update db_types
set setup_script_template ='
CREATE USER user_#databaseName# PASSWORD ''#databaseName#'';
CREATE DATABASE db_#databaseName# OWNER user_#databaseName# ENCODING ''UTF8'' TEMPLATE db_template;
'
where id = 1;
