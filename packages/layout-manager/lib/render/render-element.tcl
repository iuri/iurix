ad_page_contract {

    Render a layout element.

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date
    @cvs_id $Id: render-element.tcl,v 1.2 2008/07/30 11:59:33 donb Exp $

} {
    {-column ""}
}

#ns_log Notice "COLUMN $column"

array set element [layout::element::get_render_data -element_id $element_id]

set config $element(config)

