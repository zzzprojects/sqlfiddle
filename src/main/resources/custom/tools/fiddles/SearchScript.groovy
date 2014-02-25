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
// objectClass: a String describing the Object class (__ACCOUNT__ / __GROUP__ / other)
// action: a string describing the action ("SEARCH" here)
// log: a handler to the Log facility
// options: a handler to the OperationOptions Map
// query: a handler to the Query Map
//
// The Query map describes the filter used.
//
// query = [ operation: "CONTAINS", left: attribute, right: "value", not: true/false ]
// query = [ operation: "ENDSWITH", left: attribute, right: "value", not: true/false ]
// query = [ operation: "STARTSWITH", left: attribute, right: "value", not: true/false ]
// query = [ operation: "EQUALS", left: attribute, right: "value", not: true/false ]
// query = [ operation: "GREATERTHAN", left: attribute, right: "value", not: true/false ]
// query = [ operation: "GREATERTHANOREQUAL", left: attribute, right: "value", not: true/false ]
// query = [ operation: "LESSTHAN", left: attribute, right: "value", not: true/false ]
// query = [ operation: "LESSTHANOREQUAL", left: attribute, right: "value", not: true/false ]
// query = null : then we assume we fetch everything
//
// AND and OR filter just embed a left/right couple of queries.
// query = [ operation: "AND", left: query1, right: query2 ]
// query = [ operation: "OR", left: query1, right: query2 ]
//
// Returns: A list of Maps. Each map describing one row.
// !!!! Each Map must contain a '__UID__' and '__NAME__' attribute.
// This is required to build a ConnectorObject.

//Need to handle the __UID__ and __NAME__ in queries
def fieldMap = [
    "schema_defs": [
        "__NAME__": "s.id",
        "__UID__": "(s.db_type_id || '_' || s.short_code)",
        "last_used": "to_char(s.last_used, 'YYYY-MM-DD HH24:MI:SS.MS')",
        "minutes_since_last_used": "floor(EXTRACT(EPOCH FROM age(current_timestamp, last_used))/60)"
    ],
    "queries": [
        "__NAME__": "q.md5",
        "__UID__": "(s.id || '_' || s.short_code || '_' || q.id)"
    ]
]

def whereTemplates = [
    CONTAINS:'$left ${not ? "NOT " : ""}LIKE ?',
    ENDSWITH:'$left ${not ? "NOT " : ""}LIKE ?',
    STARTSWITH:'$left ${not ? "NOT " : ""}LIKE ?',
    EQUALS:'$left ${not ? "<>" : "="} ?',
    GREATERTHAN:'$left ${not ? "<=" : ">"} ?',
    GREATERTHANOREQUAL:'$left ${not ? "<" : ">="} ?',
    LESSTHAN:'$left ${not ? ">=" : "<"} ?',
    LESSTHANOREQUAL:'$left ${not ? ">" : "<="} ?'
]

def whereParams = []
def queryParser

queryParser = { queryObj ->

    if (queryObj.operation == "OR" || queryObj.operation == "AND") {
        return "(" + queryParser(queryObj.right) + " " + queryObj.operation + " " + queryParser(queryObj.left) + ")"
    } else {

        if (queryObj.get("operation") == "CONTAINS") {
            whereParams.push("%" + queryObj.get("right") + "%")
        } else if (queryObj.get("operation") == "ENDSWITH") {
            whereParams.push("%" + queryObj.get("right"))
        } else if (queryObj.get("operation") == "STARTSWITH") {
            whereParams.push(queryObj.get("right") + "%")
        } else if (queryObj.get("left") == "minutes_since_last_used" || queryObj.get("left") == "schema_def_id") {
            whereParams.push(queryObj.get("right").toInteger())
        } else {
            whereParams.push(queryObj.get("right"))
        }

        if (fieldMap[objectClass] && fieldMap[objectClass][queryObj.get("left")]) {
            queryObj.put("left",fieldMap[objectClass][queryObj.get("left")])
        }

        def engine = new groovy.text.SimpleTemplateEngine()
        def wt = whereTemplates.get(queryObj.get("operation"))
        def binding = [left:queryObj.get("left"),not:queryObj.get("not")]
        def template = engine.createTemplate(wt).make(binding)

        return template.toString()
    }
}

log.info("Entering "+action+" Script")

def sql = new Sql(connection)
def result = []
def where = ""

if (query != null) {
    // We can use Groovy template engine to generate our custom SQL queries
    where = "WHERE " + queryParser(query)
    //println("Search WHERE clause is: ${where} + ${whereParams}")
}

switch ( objectClass ) {
    case "schema_defs":

    sql.eachRow("""
        SELECT 
            s.id,
            s.db_type_id,
            s.short_code,
            to_char(s.last_used, 'YYYY-MM-DD HH24:MI:SS.MS') as last_used,
            floor(EXTRACT(EPOCH FROM age(current_timestamp, last_used))/60) as minutes_since_last_used,
            s.ddl,
            s.statement_separator,
            d.simple_name,
            d.full_name,
            d.context 
        FROM 
            schema_defs s 
                INNER JOIN db_types d ON 
                    s.db_type_id = d.id
        """ + where, whereParams) {

        result.add([
            __NAME__:it.id.toInteger(), 
            __UID__: it.db_type_id + '_' + it.short_code,
            id:it.id.toInteger(),
            db_type_id:it.db_type_id.toInteger(), 
            context: it.context,
            fragment: it.db_type_id + '_' + it.short_code,
            ddl: it.ddl,
            last_used:it.last_used, 
            minutes_since_last_used:it.minutes_since_last_used != null ? it.minutes_since_last_used.toInteger(): null, 
            short_code:it.short_code,
            statement_separator:it.statement_separator,
            simple_name:it.simple_name,
            full_name:it.full_name
        ])

    }
    break

    case "queries":
    sql.eachRow("""
        SELECT 
            q.schema_def_id,
            q.id,
            s.db_type_id,
            s.short_code,
            q.sql,
            q.statement_separator,
            q.md5
        FROM 
            schema_defs s 
                INNER JOIN queries q ON
                    q.schema_def_id = s.id
        """ + where, whereParams) {

        result.add([
            __NAME__:it.md5, 
            __UID__: it.db_type_id + '_' + it.short_code + '_' + it.id,
            fragment: it.db_type_id + '_' + it.short_code + '_' + it.id,
            md5: it.md5,
            id:it.id.toInteger(),
            schema_def_id:it.schema_def_id.toInteger(), 
            sql: it.sql,
            statement_separator:it.statement_separator
        ])

    }
    break

    default:
    result;
}

return result;