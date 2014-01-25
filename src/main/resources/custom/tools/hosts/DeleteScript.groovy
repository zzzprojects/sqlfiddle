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


// Parameters:
// The connector sends the following:
// connection: handler to the SQL connection
// action: a string describing the action ("DELETE" here)
// log: a handler to the Log facility
// objectClass: a String describing the Object class (__ACCOUNT__ / __GROUP__ / other)
// options: a handler to the OperationOptions Map
// uid: String for the unique id that specifies the object to delete

def sql = new Sql(connection)
def result = []

assert uid != null
switch ( objectClass ) {
    case "databases":
        String delimiter = (char) 7;
        char newline = 10;
        char carrageReturn = 13;
        
        def dbTypeMatcher = uid =~ /^db_(\d+)_.*$/;
        def db_type_id = dbTypeMatcher[0][1].toInteger();

        sql.eachRow("""\
            SELECT 
                d.id as db_type_id, 
                d.simple_name, 
                d.drop_script_template,
                d.batch_separator,
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
            WHERE 
                h.db_type_id = ?
            """, [db_type_id]) {
            def populatedUrl = it.jdbc_url_template.replace("#databaseName#", it.default_database)
            def host_id = it.host_id

            def hostConnection = Sql.newInstance(populatedUrl, it.admin_username, it.admin_password, it.jdbc_class_name);
            def drop_script = it.drop_script_template.replaceAll('#databaseName#', uid.replaceFirst("db_", ""))

            if (it.batch_separator && it.batch_separator.size()) {
                drop_script = drop_script.replaceAll(Pattern.compile(newline + it.batch_separator + carrageReturn + "?(" + newline + "|\$)", Pattern.CASE_INSENSITIVE), delimiter)
            }

            drop_script.tokenize(delimiter).each { hostConnection.execute(it) }

            hostConnection.close()
        }

}

uid;