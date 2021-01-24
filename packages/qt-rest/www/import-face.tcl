
ns_log Notice "Running TCL script import-face.tcl"

#set header [ns_conn header]
#    ns_log Notice "HEADER \n $header"
#    set h [ns_set size $header]
#    ns_log Notice "HEADERS $h"
# set req [ns_set array $header]
#   ns_log Notice "$req"


set content [ns_getcontent -as_file false]
# ns_log Notice "CONTENT $content"

#NEWCONTENT {"jsonstring":{"result":{"faces":[{"attributes":{"age":40.030380249,"eyeglasses":0,"gender":0,"emotions":{"estimations":{"anger":1e-10,"disgust":3.7e-9,"fear":1.3e-9,"happiness":0.0000082177,"neutral":0.9998919964,"sadness":0.0000998105,"surprise":7e-10},"predominant_emotion":"neutral"}},"id":"b6264b14-3747-4341-a6c5-8c62cd728802","score":0.4380833209}]},"timestamp":1611443398.9116528,"source":"descriptors","event_type":"extract","authorization":{"token_id":"b935a0e0-44ad-4b4d-ad9d-f66b3653cf34","token_data":"CCPN002"}}}


#ns_log Notice "NEWCONTENT $content"

package require rl_json
namespace path {::rl_json}


set json [json get $content jsonstring]
#ns_log notice "JSON $json"

# Import Faces
qt::dashboard::person::import -json_text $json


# Matching by Descriptor
qt::lunaapi::matching::descriptor -json $json



ns_respond -status 200 -type "text/plain" -string "OK"
ad_script_abort
