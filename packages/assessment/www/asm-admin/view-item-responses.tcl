# packages/assessment/www/asm-admin/view-item-responses.tcl

ad_page_contract {
    
    View text/date responses
    
    @author Roel Canicula (roel@solutiongrove.com)
    @creation-date 2006-06-09
    @arch-tag: d97c0cf0-0f43-4958-86ca-2a3d2816f31d
    @cvs-id $Id: view-item-responses.tcl,v 1.3.2.2 2016/05/20 20:07:42 gustafn Exp $
} {
    item_id:naturalnum,notnull
    section_id:naturalnum,notnull
    return_url:localurl,notnull
} -properties {
} -validate {
} -errors {
}

set package_id [ad_conn package_id]
permission::require_permission -object_id $package_id -privilege create

set as_item_id [content::item::get_latest_revision -item_id $item_id]
set data_type [db_string get_data_type {
    select data_type
    from as_items
    where as_item_id = :as_item_id
}]

if { $data_type eq "date" || $data_type eq "timestamp" } {
    set answer_field timestamp_field
} elseif { $data_type eq "text" } {
    set answer_field clob_answer
} else {
    set answer_field text_answer
}

db_multirow -extend { session_url user_url file_url } responses responses [subst {
    select item_data_id, subject_id, session_id, $answer_field as answer,
    person__name(subject_id) as person_name

    from as_item_data
    where as_item_id = :as_item_id
    and $answer_field is not null
}] {
    set user_url [export_vars -base sessions { subject_id }]
    set session_url [export_vars -base ../session { session_id }]
    
    if { $data_type eq "file" } {
	set file_url [as::item_display_f::view \
			  -item_id $as_item_id \
			  -session_id $session_id \
			  -section_id $section_id]
    }
}

template::list::create \
    -name responses \
    -multirow responses \
    -no_data "[_ assessment.No_responses]" \
    -pass_properties { data_type } \
    -elements {
	session_id {
	    label "[_ assessment.Session]"
	    link_url_col session_url
	}
	person_name {
	    label "[_ assessment.Name]"
	    link_url_col user_url
	}
	answer {
	    label "[_ assessment.Answer]"
        link_url_col file_url
	}
    }
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
