ad_page_contract {
    Schedules all -procs.tcl and xql files of a package to be watched.


    @author Peter Marklund
    @cvs-id $Id: package-watch.tcl,v 1.5 2018/02/02 00:04:50 gustafn Exp $
} {
    package_key:token
    {return_url:localurl "index"}
} 

apm_watch_all_files $package_key

ad_returnredirect $return_url
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
