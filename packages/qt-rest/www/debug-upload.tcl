
ns_log Notice "Running REST debug upload"

# Validate and Authenticate JWT
#qt::rest::jwt::validation_p


    

set header [ns_conn header]
ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"


ns_log Notice "BODY \n  [ns_getcontent -as_file false]"
package req json
set dict [json::json2dict [ns_getcontent -as_file false]]
ns_log Notice "*** ***** *** ** \n DICT \n $dict"


# set dict [json::json2dict $data]    

array set arr $dict
# ns_log Notice "BODY \n [parray arr]"
