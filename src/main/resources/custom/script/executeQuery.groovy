
import groovy.sql.Sql;
import groovy.sql.DataSet;
import java.security.MessageDigest;

def content = request.getContent().asMap();

assert content.sql
assert content.db_type_id
assert content.schema_short_code

assert content.sql.size() <= 8000

def schema_def = openidm.read("system/fiddles/schema_defs/" + content.db_type_id + "_" + content.schema_short_code)

assert schema_def != null
assert schema_def.context == "host"

// Update the timestamp for the schema_def each time this instance is used, so we know if it should stay running longer
schema_def.last_used = (new Date().format("yyyy-MM-dd HH:mm:ss.S"))
openidm.update("system/fiddles/schema_defs/" + schema_def._id, null, schema_def)

// Save a copy of this query (or retrieve the id of one that already exists)
def m = openidm.create("system/fiddles/queries", 
    null, 
    [
        "md5": "n/a",
        "sql": content.sql,
        "statement_separator": content.statement_separator,
        "schema_def_id": schema_def.id
    ]
)._id =~ /^\d+_\w+_(\d+)*$/
int queryId = m[0][1].toInteger()



// Use the presence of a link between fiddle and host db to determine if we need to provision a running instance of this db
def hostLink = openidm.query("repo/link", [
        "_queryId": "links-for-firstId",
        "linkType": "fiddles_hosts",
        "firstId" : schema_def._id
    ]).result[0]

if (hostLink == null) {
    openidm.action("recon", 
        "reconById", 
        [
            "mapping" : "fiddles_hosts",
            "ids" : schema_def._id,
            "waitForCompletion" : "true"
        ]
    )

    hostLink = openidm.query("repo/link", [
        "_queryId": "links-for-firstId",
        "linkType": "fiddles_hosts",
        "firstId" : schema_def._id
    ]).result[0]
}

// At this point we should have a link between schema definition and running db; otherwise provisioning 
// went wrong and we won't be able to connect to this db to perform our query
assert hostLink != null

// We get the details about how to connect to the running DB by doing a read on it
def hostDatabase = openidm.read("system/hosts/databases/" + hostLink.secondId)
def hostConnection = Sql.newInstance(hostDatabase.jdbc_url, hostDatabase.username, hostDatabase.pw, hostDatabase.jdbc_class_name)




def sets = []
//def sqlBatchList = (sql =~ / /).replaceAll()
hostConnection.withTransaction {

    sets.add([ RESULTS: [ COLUMNS: [], DATA: [] ] ])

    def currentSet = sets.size()-1;

    hostConnection.eachRow(content.sql, { row ->
        def meta = row.getMetaData()
        int columnCount = meta.getColumnCount()
        int i = 0
        def data = []

        if (sets[currentSet].RESULTS.COLUMNS.size() == 0) {
            for (i = 1; i <= columnCount; i++) {
                sets[currentSet].RESULTS.COLUMNS.add(meta.getColumnName(i));
            }
        }

        for (i = 0; i < columnCount; i++) {
            switch ( meta.getColumnType((i+1)) ) {
                case java.sql.Types.TIMESTAMP: 
                    data.add(row.getAt(i).format("MMMM, dd yyyy HH:mm:ss"))
                break;

                case java.sql.Types.TIME: 
                    data.add(row.getAt(i).format("MMMM, dd yyyy HH:mm:ss"))
                break;

                case java.sql.Types.DATE: 
                    data.add(row.getAt(i).format("MMMM, dd yyyy HH:mm:ss"))
                break;

                default: 
                    data.add(row.getAt(i))
            }
        }

        sets[currentSet].RESULTS.DATA.add(data)
    })

}

hostConnection.close()

[
    ID: queryId,
    sets: sets
]