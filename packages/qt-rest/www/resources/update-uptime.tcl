# packages/qt-rest/www/resources/update-uptime.tcl
ad_page_contract {
    Endpoint to update resource's active status
} {
    {resource:notnull}
}


ns_log Notice "Running TCL script  update-uptime.tcl  \n resource $resource"


if {[db_0or1row exists_p {
    SELECT id FROM qt_uptime_resources WHERE resource = :resource
}]} {
    db_transaction {
	db_exec_plsql update_uptime {
	    SELECT uptime_resources__update(:id);
	}
    }

}



ns_log Notice "SUCCESS! Resources $resource has been updated!"
ad_script_abort
