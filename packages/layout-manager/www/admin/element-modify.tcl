ad_page_contract {
    Save new moving/removing of the elements

    @author iuri sampaio (iuri.sampaio@gmail.com
    @creation-date 2/26/2004
    @cvs_id $Id: pageset-configure-2.tcl,v 1.6 2010/02/08 22:23:04 donb Exp $
} {
    pageset_id:integer,optional
    page_id:integer,optional
    element_id:integer,optional
    page_column:integer,optional
    sort_key:integer,optional
    {return_url ""}
}

ns_log Notice "PAGE element-modify.tcl"

ns_log Notice "$pageset_id | $page_id | $element_id | $page_column | $sort_key | $return_url"

permission::require_permission -object_id $pageset_id -privilege write

layout::element::move -page_id $page_id -element_id $element_id -direction up
layout::element::move -page_id $page_id -element_id $element_id -direction down
layout::element::move -page_id $page_id -element_id $element_id -direction left
layout::element::move -page_id $page_id -element_id $element_id -direction right




# Flush the world.

layout::pageset::flush -pageset_id $pageset_id
if { [exists_and_not_null page_id] } {
    layout::page::flush -page_id $page_id
}
if { [exists_and_not_null element_id] } {
    layout::element::flush -element_id $element_id
}

#ad_returnredirect $return_url
