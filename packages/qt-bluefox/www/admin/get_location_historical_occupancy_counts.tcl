ad_page_contract {}

set access_token [parameter::get_global_value -package_key qt-bluefox -parameter AccessToken -default ""]
set secret_token [parameter::get_global_value -package_key qt-bluefox -parameter SecretToken -default ""]
set content_type [parameter::get_global_value -package_key qt-bluefox -parameter ContentType -default ""]


set req_headers [ns_set create]
ns_set put $req_headers "x-api-access-token" "$access_token"
ns_set put $req_headers "x-api-secret-token" "$secret_token"
ns_set put $req_headers "Content-Type" "$content_type"

ns_log Notice "$access_token | $secret_token | $content_type"

#   set url "http://luna.qonteo.com:5000/4/storage/lists"
set proto [parameter::get_global_value -package_key qt-bluefox -parameter ProtoURL -default "https"]
set domain [parameter::get_global_value -package_key qt-bluefox -parameter DomainURL -default ""]
set path [parameter::get_global_value -package_key qt-bluefox -parameter HistoricalPath -default ""]
set url "${proto}://${domain}/${path}"

set body "\{
    \"day_span\": 7
\}"
ns_log Notice "URL $url"
set res [ns_http run -method POST -headers $req_headers -body $body $url]
#ns_log Notice "RES2 $res"


set data [dict get $res body]

package req json

set l [json::json2dict $data]
#ns_log Notice "DATA $l"
array set arr $l


#status OK occupancy_count_flooring_enabled 1 floor_occupancy_count 0 occupancy_count_slots

#ns_log Notice "$occupancy_count_slots"

foreach elem $arr(occupancy_count_slots) {
    ns_log Notice "ELEM $elem"
    set timestamp [lindex $elem 0]
    set date_from [db_string convert_timestamp {
	SELECT TIMESTAMP WITH TIME ZONE 'epoch' + :timestamp * INTERVAL '1 second'
    }]
    set timestamp [lindex $elem 1]
    set date_to [db_string convert_timestamp {
	SELECT TIMESTAMP WITH TIME ZONE 'epoch' + :timestamp * INTERVAL '1 second'
    }]
    
    ns_log Notice "DATEFROM $date_from | DATETO $date_to"
}

