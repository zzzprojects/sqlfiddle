/*
 *
 * Copyright (c) 2010 ForgeRock Inc. All Rights Reserved
 *
 * The contents of this file are subject to the terms
 * of the Common Development and Distribution License
 * (the License). You may not use this file except in
 * compliance with the License.
 *
 * You can obtain a copy of the License at
 * http://www.opensource.org/licenses/cddl1.php or
 * OpenIDM/legal/CDDLv1.0.txt
 * See the License for the specific language governing
 * permission and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL
 * Header Notice in each file and include the License file
 * at OpenIDM/legal/CDDLv1.0.txt.
 * If applicable, add the following below the CDDL Header,
 * with the fields enclosed by brackets [] replaced by
 * your own identifying information:
 * "Portions Copyrighted 2010 [name of copyright owner]"
 *
 * $Id$
 */
 
import groovy.sql.Sql;
import groovy.sql.DataSet;
import java.util.regex.Pattern;
// Parameters:
// The connector sends us the following:
// connection : SQL connection
// action: String correponding to the action ("CREATE" here)
// log: a handler to the Log facility
// objectClass: a String describing the Object class (__ACCOUNT__ / __GROUP__ / other)
// id: The entry identifier (OpenICF "Name" atribute. (most often matches the uid)
// attributes: an Attribute Map, containg the <String> attribute name as a key
// and the <List> attribute value(s) as value.
// password: password string, clear text
// options: a handler to the OperationOptions Map

log.info("Entering "+action+" Script");

def sql = new Sql(connection)

def findAvailableHost = { db_type_id ->
    def query = """\
        SELECT
            h.*
        FROM
            Hosts h
        WHERE
            db_type_id = ? AND
            not exists (
                SELECT 
                    1
                FROM
                    Hosts h2
                WHERE   
                    h2.id != h.id AND
                    h2.db_type_id = h.db_type_id AND
                    coalesce((SELECT count(s.id) FROM schema_defs s WHERE s.current_host_id = h2.id), 0) < 
                    coalesce((SELECT count(s.id) FROM schema_defs s WHERE s.current_host_id = h.id), 0)
            )    
    """;

    def row = sql.firstRow(query, [db_type_id])

    return row.id
}

//Create must return UID. Let's return the name for now.

switch ( objectClass ) {
    case "databases":
        String delimiter = (char) 7;
        char newline = 10;
        char carrageReturn = 13;

        def host_id = findAvailableHost(attributes.db_type_id.get(0))

        sql.eachRow("""\
            SELECT 
                d.setup_script_template, 
                d.batch_separator,
                d.jdbc_class_name,
                h.jdbc_url_template,
                h.default_database,
                h.admin_username,
                h.admin_password
            FROM 
                db_types d
                    INNER JOIN hosts h ON
                        d.id = h.db_type_id
            WHERE 
                h.id = ?
            """, [host_id]) {

            def setup_script = it.setup_script_template
            def batch_separator = it.batch_separator
            def populatedUrl = it.jdbc_url_template.replace("#databaseName#", it.default_database)

            def hostConnection = Sql.newInstance(populatedUrl, it.admin_username, it.admin_password, it.jdbc_class_name)

            // the setup scripts expect "databaseName" placeholders in the form of 2_abcde, 
            // but the id is the form db_2_abcde (the scripts will add the "db_" prefix as needed)
            // This could probably be made neater...
            setup_script = setup_script.replaceAll('#databaseName#', id.replaceFirst("db_", ""))

            if (batch_separator && batch_separator.size()) {
                setup_script = setup_script.replaceAll(Pattern.compile(newline + batch_separator + carrageReturn + "?(" + newline + "|\$)", Pattern.CASE_INSENSITIVE), delimiter)
            }

            def queryList = setup_script.tokenize(delimiter);

            queryList.each { hostConnection.execute(it) }

            hostConnection.close()

            populatedUrl = it.jdbc_url_template.replaceAll("#databaseName#", id)
            hostConnection = Sql.newInstance(populatedUrl, attributes.username.get(0), attributes.pw.get(0), it.jdbc_class_name)

            def ddl = ""
            if (attributes.ddl) {
                ddl = attributes.ddl.get(0)
            }

            def statement_separator = ";"
            if (attributes.statement_separator) {
                statement_separator = attributes.statement_separator.get(0)
            }

            if (batch_separator && batch_separator.size()) {
                ddl = ddl.replaceAll(Pattern.compile(newline + batch_separator + carrageReturn + "?(" + newline + "|\$)", Pattern.CASE_INSENSITIVE), delimiter)
            }

            ddl = ddl.replaceAll(Pattern.compile(statement_separator.replaceAll(/([^A-Za-z0-9])/, "\\1") + "\\s*" + carrageReturn + "?(" + newline + "|\$)", Pattern.CASE_INSENSITIVE), delimiter)

            ddl.tokenize(delimiter).each { hostConnection.execute(it) }

            hostConnection.close()

        }


    break
}

return id;
