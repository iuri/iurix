ad_page_contract {

    @author iuri sampaio (iuri.sampaio@gmail.com)
    @creation-date 2011-01-18
}


set user_id [ad_conn user_id]
set return_url [ad_conn url]

set admin_p [permission::permission_p -party_id $user_id -object_id [ad_conn package_id] -privilege "admin"]

set msgs [db_list select_messages { select count(*) from chat_invitation_queue where target_user_id = :user_id}]

set active_p [db_list select_status { select active_p from chat_availability where user_id = :user_id}]


set chat_current_status [_ chat.Unavailable]

if { [exists_and_not_null active_p]} {
    if {$active_p eq "t"} {
	set chat_current_status [_ chat.Available]
    
    }
}
   