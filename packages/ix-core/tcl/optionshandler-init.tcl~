
ns_register_proc OPTIONS /REST/* ::my_options_handler

proc ::my_options_handler args {
    ns_log notice "==== my_options_handler is called ==== "
    ns_set put [ns_conn outputheaders] Allow "OPTIONS GET POST"
    ns_return 200 text/plain {}
}
