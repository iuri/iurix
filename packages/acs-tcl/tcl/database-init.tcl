ad_library {

    Initialization code for database routines.

    @creation-date 7 Aug 2000
    @author Jon Salz (jsalz@arsdigita.com)
    @cvs-id $Id: database-init.tcl,v 1.4.4.1 2015/09/10 08:21:56 gustafn Exp $

}

#DRB: the default value is needed during the initial install of OpenACS
ns_cache create db_cache_pool -size \
    [parameter::get -package_id [ad_acs_kernel_id] -parameter DBCacheSize -default 50000]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
