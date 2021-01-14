ad_page_contract {
    Deprecates categories.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id: category-phase-out.tcl,v 1.10.2.1 2019/12/20 21:18:10 gustafn Exp $
} {
    tree_id:naturalnum,notnull
    category_id:naturalnum,multiple
    {locale:word ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
} 

permission::require_permission -object_id $tree_id -privilege category_tree_write

db_transaction {
    foreach id $category_id {
	category::phase_out $id
    }
}
category_tree::flush_cache $tree_id

ad_returnredirect [export_vars -no_empty -base tree-view { tree_id locale object_id ctx_id}]
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
