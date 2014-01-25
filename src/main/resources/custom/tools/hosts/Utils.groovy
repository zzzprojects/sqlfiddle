 
import groovy.sql.Sql;
import groovy.sql.DataSet;

class Utils {

    static def findDatabase = { schema_name, connection ->

        def sql = new Sql(connection)
        def result = []

        def dbTypeMatcher
        def dbTypeWhere = ""
        def dbTypeWhereParams = []

        if (schema_name) {
            // try to find the db_type_id from within the schema_name. Schema_names have the format of db_X_abcde, where X is the db_type_id
            dbTypeMatcher = schema_name =~ /^db_(\d+)_.*$/;
            if (dbTypeMatcher.size() == 1 && dbTypeMatcher[0].size() == 2) {
                dbTypeWhere = " WHERE h.db_type_id = ?"
                dbTypeWhereParams = [dbTypeMatcher[0][1].toInteger()]
            }

        }

        sql.eachRow("""\
            SELECT 
                d.id as db_type_id, 
                d.simple_name, 
                d.list_database_script, 
                d.jdbc_class_name, 
                h.id as host_id, 
                h.jdbc_url_template, 
                h.default_database, 
                h.admin_username, 
                h.admin_password 
            FROM 
                db_types d 
                    INNER JOIN hosts h ON 
                        d.id = h.db_type_id
            """ + dbTypeWhere, dbTypeWhereParams) {
            def populatedUrl = it.jdbc_url_template.replace("#databaseName#", it.default_database)

            def db_type_id = it.db_type_id
            def host_id = it.host_id

            def schemaNameWhere = ""
            def schemaNameWhereParams = []

            if (schema_name) {
                if (it.simple_name == "MySQL") {
                    schemaNameWhere = " WHERE `Database` = ?"
                } else {
                    schemaNameWhere = " WHERE schema_name = ?"
                }
                schemaNameWhereParams = [schema_name]
            }

            def hostConnection = Sql.newInstance(populatedUrl, it.admin_username, it.admin_password, it.jdbc_class_name);
            hostConnection.eachRow(it.list_database_script + schemaNameWhere, schemaNameWhereParams) {
                result.add([
                    __UID__:it.getAt(0),
                    __NAME__:it.getAt(0),
                    db_type_id: db_type_id,
                    host_id: host_id
                ])
            }
            hostConnection.close()
        }

        sql.close()

        return result;

    }

}