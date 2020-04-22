ad_page_contract {}


set base_url "https://api.sandbox.paypal.com"

set url ${base_url}/v1/oauth2/token
set client_id "AWPWKH8kF7PmtngnMwIfjrUszGvPLtttsWQQ8FVpufXpcsED4tguctP1ikBC73jimnmcRtF580nE_Hhg"
set secret "EAKxYZcZlJfH1wEzd0ovJpg2pJHzHwYdIFf45bKSi2x5FdfzPxLDa30z2cPvJLSA_Y4SKRNOk410r3Tg"

# lassign [pp_status_data $status] base_url client_id secret
if {[catch {set result [exec curl -s $url \
			    -H "Accept: application/json" \
			    -H "Accept-Language: en_US" \
			    -u "${client_id}:${secret}" \
			    -d "grant_type=client_credentials"]} errmsg]} {

    ns_log Notice "ERROR CURL \n $errmsg"
    set result ""
} else {
    package require json
    set result [json::json2dict $result]
    set result [list [dict get $result access_token] [dict get $result expires_in] [dict get $result app_id]]
}


ns_log Notice "RESULT \n $result"





# lassign [pp_status_data $status] base_url client_id secret
set h [ns_set create]
ns_set update $h Authorization "Basic [ns_base64encode ${client_id}:${secret}]"
ns_set update $h Accept "application/json"
ns_set update $h Accept-Language "en_US"
set b "grant_type=client_credentials"
set m POST
if {[catch { set result2 [ns_http run -method $m -headers $h -body $b $url]} errmsg]} {
    ns_log Notice "ERROR NSHTTP"
    set result2 ""
} else {

#    package require json
#    set result [json::json2dict $result]
#    set result [list [dict get $result access_token] [dict get $result expires_in]]

}
# ns_log Notice "RESULT \n $result2"






set pp_token [lindex $result 0]
set app_id [lindex $result 2]

set url "https://api.sandbox.paypal.com/v1/payment-experience/web-profiles/$app_id"

ns_log Notice "URL $url"
ns_log Notice "TOKEN $pp_token"

# lassign [pp_status_data $status] base_url client_id secret
if {[catch {set result3 [exec curl -s $url \
			     -H "Content-Type: application/json" \
			     -H "Authorization: Bearer $pp_token"]} errmsg]} {
    
    ns_log Notice "ERROR CURL \n $errmsg"
    set result3 ""
} else {

}
# ns_log notice "NEW RESULT \n $result3"






# RESULT 4 INVOICING
# set url "https://api.sandbox.paypal.com/v1/payment-experience/web-profiles"



# RESULT 5 WEBPROFILES
set url "https://api.sandbox.paypal.com/v1/payment-experience/web-profiles"

# lassign [pp_status_data $status] base_url client_id secret
if {[catch {set result4 [exec curl -s $url \
			     -H "Content-Type: application/json" \
			     -H "Authorization: Bearer $pp_token"]} errmsg]} {
    
    ns_log Notice "ERROR CURL \n $errmsg"
    set result4 ""
} else {

}
# ns_log notice "NEW RESULT \n $result4"



# ORDERS

set url ${base_url}/v2/checkout/orders
# lassign [pp_status_data $status] base_url client_id secret

set d "\{
  \"intent\": \"CAPTURE\",
    \"purchase_units\": \[
		       \{
			   \"amount\": \{
        \"currency_code\":  \"USD\",
        \"value\": \"100.00\"
			   \}
		       \}
		       \]
\}"


if {[catch {set result4 [exec curl -s $url \
			     -H "Content-Type: application/json" \
			     -H "Authorization: Bearer $pp_token" \
			     -d $d]} errmsg]} {
    
    ns_log Notice "ERROR CURL \n $errmsg"
    set result4 ""
} else {

}



ns_log Notice "$result4"
