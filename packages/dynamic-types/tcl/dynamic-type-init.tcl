ad_library {
    Register attribute callbacks.

    @author Lee Denison (lee@xarg.net)
    @creation-date 2004/11/11
    @cvs-id $Id: dynamic-type-init.tcl,v 1.5 2005/09/04 12:13:28 maltes Exp $
} 

util::event::register -event dtype \
    -match { action (updated|deleted) } \
    { dtype::flush_cache -type $type -event event }

util::event::register -event dtype.attribute \
    -match { action (created|updated|deleted) } \
    { dtype::flush_cache -type $type -event event }
