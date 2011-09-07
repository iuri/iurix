ad_library {

    Install and upgrade callback procs

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-09-04
}
    

namespace eval mores::install {}

ad_proc -private mores::install::add_scheduled_procs {} {
    Add scheduled procs 
} {

    ad_schedule_proc 60 mores::util::sync_microblog
    ad_schedule_proc 120 mores::util::sync_medias
    ad_schedule_proc 3600 mores::util::sync_all
}


