ad_page_contract {

    Forwarding email is difeferent from rebalacing email. Both features can be implemented
    

} {
    {mail_id:naturalnum,notnull}

}



ad_returnredirect [export_vars -base mail-one {msg mail_id}] 
ad_acript_abort
