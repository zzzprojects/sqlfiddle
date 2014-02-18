/**/
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

def hostLink = openidm.query("repo/link", [
        "_queryId": "links-for-firstId",
        "linkType": "fiddles_hosts",
        "firstId" : schema_def._id
    ]).result[0]

schema_def.last_used = (new Date().format("yyyy-MM-dd HH:mm:ss.S"))
openidm.update("system/fiddles/schema_defs/" + schema_def._id, null, schema_def)

if (hostLink == null) {

    def recon = openidm.action( "recon", 
                    "reconById", 
                    [
                        "mapping" : "fiddles_hosts",
                        "ids" : schema_def._id,
                        "waitForCompletion" : true
                    ]
                )

    hostLink = openidm.query("repo/link", [
        "_queryId": "links-for-firstId",
        "linkType": "fiddles_hosts",
        "firstId" : schema_def._id
    ]).result[0]

}

assert hostLink != null

def hostDatabase = openidm.read("system/hosts/databases/" + hostLink.secondId)
def hostConnection = Sql.newInstance(hostDatabase.jdbc_url, hostDatabase.username, hostDatabase.pw, hostDatabase.jdbc_class_name)
def digest = MessageDigest.getInstance("MD5")

if (content.statement_separator != ";") {
    md5hash = new BigInteger(
                        1, digest.digest( content.sql.getBytes() )
                    ).toString(16).padLeft(32,"0")
} else {
    md5hash = new BigInteger(
                        1, digest.digest( (content.statement_separator + content.sql).getBytes() )
                    ).toString(16).padLeft(32,"0")
}

def existingQuery = openidm.query("system/fiddles/queries", [ "_queryFilter": 'md5 eq "' + md5hash + '" and schema_def_id eq ' + schema_def.id])

def queryId = ""

if (existingQuery.result.size() == 0) {
    def newQuery = openidm.create("system/fiddles/queries", null, [
        "md5": md5hash,
        "sql": content.sql,
        "statement_separator": content.statement_separator,
        "schema_def_id": schema_def.id
    ])
    def m = newQuery._id =~ /^\d+_\w+_(\d+)*$/
    queryId = m[0][1].toInteger()
} else {
    queryId = existingQuery.result[0]._id
}

def sets = []

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

hostConnection.close()

[
    ID: queryId,
    sets: sets
]