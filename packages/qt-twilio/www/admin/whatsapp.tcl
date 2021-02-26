ad_page_contract {}

ns_log Notice "RECEIVE POST - Request Message from Twilio API"

set header [ns_conn header]
ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"

set content  [ns_getcontent -as_file false]
ns_log Notice "COENTNT $content"


set username [parameter::get_global_value -package_key qt-twilio -parameter AccountSID -default ""]
set token [parameter::get_global_value -package_key qt-twilio -parameter AuthToken -default ""]
set source [parameter::get_global_value -package_key qt-twilio -parameter WhatsAppDefaultNumber -default ""]


set url "https://api.twilio.com/2010-04-01/Accounts/${username}/Messages.json"
#set url "https://dashboard.qonteo.com/twilio/whatsapp"

set auth_token [join [ns_base64encode ${username}:${token}] ""]

set req_headers [ns_set create]
ns_set update $req_headers Authorization "Basic $auth_token"
ns_set update $req_headers Content-Type "multipart/form-data"

set req1 [ns_set array $req_headers]
ns_log Notice "REQ HEADER $req1"


set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body "Hello from Qonteo! Welcome! We're glad to read from you!"}}]

ns_log Notice "SEND POST REquest - Message to Twilio API"
set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
ns_log Notice "RES2 $res"


