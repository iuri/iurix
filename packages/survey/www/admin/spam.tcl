ad_page_contract {
    @author Iuri Sampaio (iuri.sampaio@gmail.com)
    @creation-date Jan 19, 2002
    @version $Id: spam.tcl,v 1.4 2006/10/25 12:27:58 eduardos Exp $
} -query {
	{user_id:multiple ""}
    {recipients:integer,multiple ""}
    {recipients_str:multiple ""}
    {group_id ""}
    {survey_id ""}
    {referer "group"}
    {spam_all 0}
} -validate {

    recipients_split {
	# Make recipients look like user_id
	if {$user_id ne ""} { 
		set recipients $user_id
	}
	if { [info exists recipients_str] && ![info exists recipients] } {
	    set recipients [split $recipients_str]	
	}
    }    
    recipients_specified {
	# Make recipients look like user_id
	if {$user_id ne ""} { 
		set recipients $user_id
	}

	set recipients_p 0	

	if  {[info exists recipients] && ![empty_string_p $recipients]} {
	    set recipients_p 1
	} elseif {[info exists spam_all] && $spam_all != 0} {
	    set recipients_p 1
	} elseif { [info exists recipients_str] && ![empty_string_p $recipients_str] } {
	    set recipients_p 1
	} elseif { [exists_and_not_null country] } {
	    set recipients_p 1
	}
	
	if { $recipients_p == 0} {
	    if {[exists_and_not_null community_id]} {
		# This is call using the old URL reference
		ad_returnredirect "spam-recipients?referer=$referer"
	    } else {
		ad_complain "[_ survey.Must_specify_recipients]"
	    }
	}
    }
    if_bad_combination {
	# Make recipients look like user_id
	if {$user_id ne ""} { 
		set recipients $user_id
	}
	if { $spam_all && ( ![empty_string_p $recipients] ) } {
	    ad_complain "You can't select roles or recipients if you have selected the \"send to everyone\" option"
	}
    }
} -properties {
    context:onevalue
    portal_id:onevalue
}


# Debug form! This chunk must be erased later                                                                                                                
set myform [ns_getform]
if {[string equal "" $myform]} {
    ns_log Notice "No Form was submited"
} else {
    ns_log Notice "FORM"
    ns_set print $myform
    for {set i 0} {$i < [ns_set size $myform]} {incr i} {
	set varname [ns_set key $myform $i]
	set $varname [ns_set value $myform $i]
    }
}

ns_log Notice "$recipients"
ns_log Notice "SURVEY ID $survey_id"

# Make recipients look like user_id
if {$user_id ne ""} { 
	set recipients $user_id
}

set spam_name [bulk_mail::parameter -parameter PrettyName -default [_ survey.Spam]]
set context [list [list $referer [_ survey.Admin]] "$spam_name [_ survey.Group]"]


set sender_id [ad_conn user_id]
set subsite_id [ad_conn subsite_id]
db_1row select_group_id {
    SELECT group_id FROM groups WHERE group_name = (select title from acs_objects WHERE object_type = 'application_group' AND context_id = :subsite_id)
} 

db_1row select_sender_info {}

# names can have single quotes in them, and since they are being selected
# from the database as literals down below, when the sender_info query is
# passed to bulk_mail::new, we have to make sure they are properly quoted
set sender_first_names [db_quote $sender_first_names]
set sender_last_name [db_quote $sender_last_name]



form create spam_message

element create spam_message group_id \
    -label "[_ survey.Group_ID]" \
    -datatype integer \
    -widget hidden \
    -value $group_id

element create spam_message from \
    -label [_ survey.From] \
    -datatype text \
    -widget hidden \
    -html {size 60} \
    -value $sender_email

element create spam_message subject \
    -label [_ survey.Subject] \
    -datatype text \
    -widget text \
    -html {size 60}

element create spam_message message \
    -label [_ survey.Message] \
    -datatype richtext \
    -widget richtext \
    -html {rows 40 cols 100 wrap soft}


element create spam_message format \
    -label "Format" \
    -datatype text \
    -widget select \
    -options {{"Preformatted Text" "pre"} {"Plain Text" "plain"} {HTML "html"}}


element create spam_message send_date \
    -label [_ survey.Send_Date] \
    -datatype date \
    -widget date \
    -format {MONTH DD YYYY HH12 MI AM} \
    -value [template::util::date::now_min_interval]

element create spam_message referer \
    -label [_ survey.Referer] \
    -datatype text \
    -widget hidden \
    -value $referer

element create spam_message recipients_str \
    -label Recipients \
    -datatype text \
    -widget hidden \
    -value $recipients \

element create spam_message survey_id \
    -label [_ survey.ID] \
    -datatype integer \
    -widget hidden \
    -value $survey_id

element create spam_message spam_all \
    -label spam \
    -datatype text \
    -widget hidden \
    -value $spam_all

if { [ns_queryexists "form:confirm"] } {
    form get_values spam_message \
         group_id from subject message send_date referer recipients_str spam_all format
    
    set who_will_receive_this_clause ""
    
    set group_name [db_string { select group_name from groups where group_id = :group_id}]
    set group_url "http://iurix.com"
    
    if { ![empty_string_p $recipients_str] } {
	set recipients_str [join [split $recipients_str] ,]
	append who_will_receive_this_clause [db_map recipients_clause]
    } 
 
 
    set safe_group_name [db_quote $group_name]
	
	# Put the no reply address
	set no_reply "no-reply@[parameter::get_from_package_key -package_key notifications -parameter EmailDomain -default openacs.org]"
	set person_email $from
	set from $no_reply

    set query [db_map sender_info]

    if {$format == "html"} {
	set message [template::util::richtext::get_property html_value $message]
	set message_type "html"
    } elseif {$format == "pre"} {
	set message [template::util::richtext::get_property contents $message]
	set message_type "html"
    } else {
	set message [template::util::richtext::get_property contents [ad_quotehtml $message]]
	set message_type "text"
    }

    
    append message "\n "


    bulk_mail::new \
        -package_id [site_node_apm_integration::get_child_package_id -package_key [bulk_mail::package_key]] \
        -send_date [template::util::date::get_property linear_date $send_date] \
        -date_format "YYYY MM DD HH24 MI SS" \
        -from_addr $no_reply \
	-reply_to $person_email \
        -subject "\[$group_name\] $subject" \
	-extra_headers "Reply-To {$person_email} Return-Path {$no_reply}" \
        -message $message \
        -message_type $message_type \
        -query $query

    ad_returnredirect ""
    ad_script_abort
}

if {[form is_valid spam_message]} {

    set confirm_data [form export]
    append confirm_data {<input type="hidden" name="form:confirm" value="confirm">}
    template::set_file "[file dir $__adp_stub]/spam-2"

}

ad_return_template
