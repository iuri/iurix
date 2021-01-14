ad_page_contract {
    This deletes a note

    @author Your Name (you@example.com)
    @cvs-id $Id: note-delete.tcl,v 1.5 2018/01/19 21:23:51 gustafn Exp $
 
    @param item_id The item_id of the note to delete
} {
    item_id:integer
}

permission::require_write_permission -object_id $item_id
set title [content::item::get_title -item_id $item_id]
mfp::note::delete -item_id $item_id

ad_returnredirect "."
# stop running this code, since we're redirecting
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
