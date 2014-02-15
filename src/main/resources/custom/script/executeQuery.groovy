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
println("system/fiddles/schema_defs/" + content.db_type_id + "_" + content.schema_short_code)
assert schema_def != null
println(schema_def._id)
def hostLink = openidm.query("repo/link", [
        "_queryId": "links-for-firstId",
        "linkType": "fiddles_hosts",
        "firstId" : schema_def._id
    ]).result[0];

schema_def.last_used = (new Date().format("yyyy-MM-dd HH:mm:ss.S"));
openidm.update("system/fiddles/schema_defs/" + schema_def._id, null, schema_def);

if (hostLink == null) {
    println("No current host!")
    openidm.action( "recon", 
                    "reconById", 
                    [
                        "mapping" : "fiddles_hosts",
                        "ids" : schema_def._id,
                        "waitForCompletion" : true
                    ]
                )
    println("ReconById completed")
} else {
    println("Link found to " + hostLink.secondId)
}

def digest = MessageDigest.getInstance("MD5")

if (content.statement_separator != ";") {
    md5hash = new BigInteger(
                        1, digest.digest( content.sql.getBytes() )
                    ).toString(16).padLeft(32,"0");
} else {
    md5hash = new BigInteger(
                        1, digest.digest( (content.statement_separator + content.sql).getBytes() )
                    ).toString(16).padLeft(32,"0");
}

[ "md5": md5hash ];