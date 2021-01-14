#      Initializes data structures for the installer.

#      @creation-date 02 October 2000
#      @author Bryan Quinn
#      @cvs-id $Id: installer-init.tcl,v 1.5 2018/07/10 19:24:50 hectorr Exp $


# Create a mutex for the installer
nsv_set acs_installer mutex [ns_mutex create oacs:installer]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
