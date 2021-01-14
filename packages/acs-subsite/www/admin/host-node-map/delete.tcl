ad_page_contract {
    @author Mark Dettinger (mdettinger@arsdigita.com)
    @creation-date 2000-10-24
    @cvs-id $Id: delete.tcl,v 1.6 2018/01/19 14:09:48 gustafn Exp $
} {
    host
    node_id:naturalnum,notnull
}

# Flush the cache
util_memoize_flush_regexp "rp_lookup_node_from_host"

db_dml host_node_delete {
    delete from host_node_map 
    where host = :host
    and node_id = :node_id
}

ad_returnredirect index
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
