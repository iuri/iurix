# /packages/qt-dashboard/tcl/qt-dashboard-procs.tcl

ad_library {

    Utility functions for Qonteo Dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020

}


namespace eval qt {}
namespace eval qt::dashboard {}
namespace eval qt::websocket {}


ad_proc qt::websocket::listen {} {
    It listens to Luna Stats & Events Service to get data faces in the json format
} {
    
    package require json
    package require rl_json
    namespace path {::rl_json}
    
    
    set WebSocketUri [parameter::get_global_value -parameter "WebSocketUri" -package_key "qt-dashboard" -default ""]
    
    # set url "ws://192.199.241.130:5008/api/subscribe?auth_token=9fb6e731-b342-4952-b0c1-aa1d0b52757b&event_type=extract"
    #set url "wss://javascript.info/article/websocket/demo/hello"
    
    if {$WebSocketUri ne ""} {
	set channel [ws::client::open $WebSocketUri]
	
	while {1} {
	    set status_p [parameter::get_global_value -parameter "WebSocketListenStatusP" -package_key "qt-dashboard" -default 0]	    
	    if {$status_p eq 0} {
		ws::client::close $channel   
		break
	    }
	    
	    set result [ws::client::receive $channel]
	    set l_json [json get [lindex $result 0]]
	    array set arr $l_json
	    
	    if { [lindex $arr(result) 0] eq "faces"} {
		qt::dashboard::import_json -l_json $l_json
	    }	    	    	    
	}
    }
}

