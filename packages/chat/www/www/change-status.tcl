ad_page_contract {
    @author Iuri Sampaio
    @creation-date 2011-02-18
} {
    {return_url ""}
}


set user_id [ad_conn user_id]

chat::change_availability -user_id $user_id


ad_returnredirect $return_url