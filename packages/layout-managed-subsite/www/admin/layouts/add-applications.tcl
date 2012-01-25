ad_page_contract {

    Generate a list of applications that are supported by includelets.

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date 
    @cvs-id $Id: add-applications.tcl,v 1.4 2010/01/08 21:12:06 emmar Exp $
}

set doc(title) [_ layout-managed-subsite.Add_applications]
set context [list $doc(title)]
set return_url [ad_conn url]?[ad_conn query]
ad_return_template
