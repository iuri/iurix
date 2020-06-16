ad_page_contract {
    @param product_id
    @param rating
    @param one_line_summary
    @param user_comment
    @param comment_id
    @param usca_p:optional

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    product_id:naturalnum,notnull
    rating
    {one_line_summary ""}
    user_comment
    {comment_id:integer 0}
    usca_p:optional
    {return_url ""}
} -validate {
    rating_user_comment_p -requires {rating} {
	if {![info exists rating] || ![info exists user_comment] } {
	    ad_returnredirect [ad_return_url]
	    ad_script_abort
	}
    }
}

set myform [ns_getform]
if {[string equal "" $myform]} {
    ns_log Notice "No Form was submited"
} else {
    ns_log Notice "FORM"
    ns_set print $myform
    for {set i 0} {$i < [ns_set size $myform]} {incr i} {
	set varname [ns_set key $myform $i]
	set varvalue [ns_set value $myform $i]

	ns_log Notice " $varname - $varvalue"
    }
}


ns_log Notice "Running TCL script review-submit-3.tcl"

# we need them to be logged in
set user_id [ad_conn user_id]
if {$user_id == 0} {
    ad_returnredirect "https://www.evex.co${return_url}"
    
    if [info exists usca_p] {
	set return_url "[ad_conn url]?[export_url_vars product_id rating one_line_summary user_comment comment_id usca_p]"
    } else {
	set return_url "[ad_conn url]?[export_url_vars product_id rating one_line_summary user_comment comment_id]"
    }
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# user session tracking
if {$comment_id eq 0} {
    set comment_id [db_nextval "ec_product_comment_id_sequence"]
}

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary [export_entire_form_as_url_vars]

# See if the review is already in there, meaning they pushed reload,
# in which case, just show the thank you message, otherwise insert the
# review

db_1row product_name_and_double_click_check "
   select product_name, comment_found_p
   from ec_products, (
	select count(*) as comment_found_p
        from ec_product_comments
        where comment_id = :comment_id)
   where product_id = :product_id"

if { !$comment_found_p } {
    set ns_conn_peeraddr [ns_conn peeraddr]

    set one_line_summary [util_close_html_tags $user_comment "27" "27" " ..." ""]

    
    db_transaction {
	db_dml insert_new_comment {
	    insert into ec_product_comments
	    (comment_id, product_id, user_id, user_comment, one_line_summary, rating, comment_date, last_modified, last_modifying_user, modified_ip_address)
	    values
	    (:comment_id, :product_id, :user_id, :user_comment, :one_line_summary, :rating, sysdate, sysdate, :user_id, :ns_conn_peeraddr)
	}
    }
}

set comments_need_approval [ad_parameter -package_id [ec_id] ProductCommentsNeedApprovalP]
# set product_link "[ec_insecurelink product?[export_url_vars product_id]]"
set product_link "https://www.evex.co${return_url}?msg=success"
set title "Thank You For Your Review of ${product_name}"
set context [list $title]
set ec_system_owner [ec_system_owner]


## Add feaure t oconnect to Google Places API - That can cause a great impact! 

db_release_unused_handles



if {[catch { acs_mail_lite::send -send_immediately -to_addr contato@evex.co -from_addr noreply@evex.co -reply_to postmaster@evex.co -subject "EvEx - Nova Avaliacao de item!" -body "$product_name  \n $nome \n Opção: $product_name \n Período: $period" -mime_type "text/html" } errmsg] } {
    ns_log Notice "ERROR SENDING EMAIL $errmsg"
}



ad_returnredirect "https://www.evex.co$return_url?msg=success"
ad_return_template
