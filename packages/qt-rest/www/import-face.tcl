
ns_log Notice "Running TCL script import-face.tcl"

#set header [ns_conn header]
#    ns_log Notice "HEADER \n $header"
#    set h [ns_set size $header]
#    ns_log Notice "HEADERS $h"
# set req [ns_set array $header]
#   ns_log Notice "$req"


set content [ns_getcontent -as_file false]
ns_log Notice "CONTENT $content"
# set content [list {"jsonstring":{"result":{"faces":[{"attributes":{"age":37.7406692505,"eyeglasses":0,"gender":1,"emotions":{"estimations":{"anger":1e-7,"disgust":0.0000174944,"fear":1.492e-7,"happiness":0.000032806,"neutral":0.9995579123,"sadness":0.0000371997,"surprise":0.0003542635},"predominant_emotion":"neutral"}},"id":"98c54bf1-a678-4093-af3d-ddb0758099fd","score":0.9149662256}]},"timestamp":1596147330.6804357,"source":"descriptors","event_type":"extract","authorization":{"token_id":"df498422-6331-4580-ac63-aac5746eacab","token_data":"PRIMAX"}}}]


#ns_log Notice "NEWCONTENT $content"

package require rl_json
namespace path {::rl_json}


set json [json get $content jsonstring]
# ns_log notice "JSON $json"

qt::dashboard::person::import -json_text $json

ns_respond -status 200 -type "text/plain" -string "OK"
ad_script_abort
