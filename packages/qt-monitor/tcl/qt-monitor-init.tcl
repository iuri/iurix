ad_library {

    Init procs for qt_dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020
    
}

ad_schedule_proc -thread t 600 qt::monitor::resource::check_availability

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:

