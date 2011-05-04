set time_now [db_string select_time {
    select now() FROM  dual
}

ns_log notice "$time_now"