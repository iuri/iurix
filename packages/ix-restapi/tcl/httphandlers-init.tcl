
ns_register_proc OPTIONS /REST/* ::my_options_handler
# ns_register_proc PUT /REST/* ::edit

# ns_register_tcl -options {stream stricterror} -- PUT /REST/*.tcl
ns_register_tcl PUT /REST/ "/var/www/iurix/packages/ix-restapi/www/users/edit.tcl"

proc ::my_options_handler args {
    ns_log notice "==== my_options_handler is called ==== "
    ns_set put [ns_conn outputheaders] Allow "OPTIONS GET POST PUT"

    ns_return 200 text/plain {}
}

#proc ::edit args {
#    ns_log notice "==== USER EDIT called ==== "
#    ix_rest::user::edit
#}
