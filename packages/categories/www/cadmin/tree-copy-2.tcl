ad_page_contract {

    This page copies a category tree into another category tree

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id: tree-copy-2.tcl,v 1.10.2.1 2019/12/20 21:18:10 gustafn Exp $
} {
    target_tree_id:naturalnum,notnull
    source_tree_id:naturalnum,notnull
    {locale:word ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
}

set user_id [auth::require_login]
set tree_id $target_tree_id
permission::require_permission -object_id $tree_id -privilege category_tree_write

category_tree::copy -source_tree $source_tree_id -dest_tree $target_tree_id

ad_returnredirect [export_vars -no_empty -base tree-view {tree_id locale object_id ctx_id}]
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
