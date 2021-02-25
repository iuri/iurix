ad_page_contract {}

ns_log Notice "RECEIVE POST - Request Message from Twilio API"

ns_log Notice "Hello Whatsapp from Twilio!"


set header [ns_conn header]
ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"

set content  [ns_getcontent -as_file false]
ns_log Notice "COENTNT $content"



set url "https://api.twilio.com/2010-04-01/Accounts/ACe13c431fe7a0339882f57e87c4b4db37/Messages.json"

#set url "https://dashboard.qonteo.com/twilio/whatsapp"

set username "ACe13c431fe7a0339882f57e87c4b4db37"
set token "7863396e735d48a4a4d4379d06ad1af6"
set auth_token [join [ns_base64encode ACe13c431fe7a0339882f57e87c4b4db37:7863396e735d48a4a4d4379d06ad1af6] ""]

set req_headers [ns_set create]
ns_set update $req_headers Authorization "Basic $auth_token"
ns_set update $req_headers Content-Type "multipart/form-data"

set req1 [ns_set array $req_headers]
ns_log Notice "REQ HEADER $req1"


set data [list]
lappend data "[ns_urlencode To]=[ns_urlencode whatsapp:+5511998896571]"
lappend data "[ns_urlencode From]=[ns_urlencode whatsapp:+14155238886]"
#lappend data "[ns_urlencode Body]=[ns_urlencode \"Your Yummy Cupcakes Company order of 1 dozen frosted cupcakes has shipped and shoul d be delivered\"]"




set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From "whatsapp:+14155238886"} {Body "Hello from Qonteo! Welcome! We're glad to read from you!"}}]


# set res [ns_http run -method POST -headers $req_headers -body $data $url]


ns_log Notice "SEND POST REquest - Message to Twilio API"
set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
ns_log Notice "RES2 $res"



# curl 'https://api.twilio.com/2010-04-01/Accounts/ACe13c431fe7a0339882f57e87c4b4db37/Messages.json' -X POST --data-urlencode 'To=whatsapp:+5511998896571' --data-urlencode 'From=whatsapp:+14155238886' --data-urlencode 'Body=Your appointment is coming up on July 21 at 3PM' -u ACe13c431fe7a0339882f57e87c4b4db37:7863396e735d48a4a4d4379d06ad1af6

