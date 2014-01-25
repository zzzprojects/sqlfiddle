
/*global security */

logger.debug("Augment context for: {}", security.username);

var userDetail,
    params,
    rolesArr,
    resource = request.attributes.get("org.forgerock.security.context").get("passThroughAuth");

if (security && security.username && security.username !== "anonymous"
    && (!(security.userid && security.userid.id && security.userid.component && security["openidm-roles"]))) {

    if (security && security.username) {

        userDetail = openidm.query(resource, {
            'query' : {
                'Contains' : {
                    'field' : 'sAMAccountName',
                    'values' : [
                        security.username
                    ]
                }
            }
        });
    }

    if (userDetail && userDetail.result && userDetail.result.length === 1) {
        // Only augment userid if missing
        if (!security.userid || !security.userid.id) {
            security.userid = {"component" : resource, "id" : userDetail.result[0]._id };
        }
        // Only augment roles if missing
        if (!security["openidm-roles"] || (!security["openidm-roles"].length && userDetail.result[0].memberOf.length)) {
            rolesArr = userDetail.result[0].memberOf;
            security["openidm-roles"] = rolesArr;
        }
        logger.debug("Augmented context for {} with userid : {}, roles : {}", security.username, security.userid, security["openidm-roles"]);
    } else {
        if (userDetail && userDetail.result && userDetail.result.length > 1) {
            throw {
                "openidmCode" : 401,
                "message" : "Access denied, user detail retrieved ambiguous"
            };
        } else {
            throw {
                "openidmCode" : 401,
                "message" : "Access denied, no user detail could be retrieved"
            };
        }
    }
}
