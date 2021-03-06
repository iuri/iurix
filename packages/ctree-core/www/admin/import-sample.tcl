ad_page_contract {}


# https://github.com/F4IF/ctree-demo/blob/mvp/firebase-export.json


package require json
package require rl_json
namespace path {::rl_json}
ad_proc import_json {
    -url
} {
    Gets full JSON, converts JSON's response to TCL array, then converts the array into a TCL list, suing rl_json library, isolates page into @data and gets @item_id directly, accessing data with list poperties
} {
    # Gets full JSON file
    set fp [open "/var/www/iurix/www/data-export.json" r]
    set json [read $fp]    
    close $fp
#    ns_log Notice "FILE \n $json"

    # TCLlib JSON
    set l_data [json::json2dict $json]
    #    ns_log Notice "TCLLIB \n $l_data"

    if {[lindex $l_data 0] eq "ctrees"} {
	# import_trees -data [lindex $l_data 1]
    }
    
    # RL_JSON
    set t [json get $json]
#    ns_log Notice "T \n $t"
    array set arr $t
    #   ns_log Notice "RL_JSON \n $arr(ctrees)"
    array set arr2 $arr(ctrees)
    ns_log notice "ARRAY2 \n [parray arr2] \n\n"
    
    # https://www.tcl.tk/man/tcl8.4/TclCmd/array.htm
    # https://wiki.tcl-lang.org/page/RL_JSON+Extensions
    set parent_id [ad_conn package_id]

    foreach name [array names arr2] {
	
	#set name [util_text_to_url [string map {á a à a â a ã a ç c é e è e ê e í i ó o õ o ô o ú u "´" "" "'" "" " " - "," - } [string tolower $name]]]

	ns_log Notice "ADD TREE: $name \n ATTRIBS $arr2($name) \n LENGTH [llength $arr2($name)]"

	ctree::tree::new -name $name -parent_id [ad_conn package_id] -content_type ctree -attributes "$arr2($name)" -add_p t
    }   
    return $json
}




set url "https://iurix.com/ctree/resources/data-export.json"
    
set json [import_json -url $url]

# doc_return 200 "application/json" $json

ad_returnredirect [export_vars -base "index" {{msg "Data Successfully Imported"}}]
ad_script_abort
