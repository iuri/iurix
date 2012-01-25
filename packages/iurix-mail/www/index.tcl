ad_page_contract {
    
    @author Iuri Sampaio (iuri.sampaio@iurix.com)
}

auth::require_login

set user_id [ad_conn user_id]

set action [list]
set bulk_actions [list]

lappend actions "#iurix-mail.Compose_mail#" compose-mail "#iurix-mail.Compose_mail#"

lappend bulk_actions {"#iurix-mail.Delete_emails#" "delete-emails" "#iurix-mail.Delete_emails#"}

template::list::create \
    -name emails \
    -multirow emails \
    -key mail_id \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars {return_url} \
    -elements {
	subject {
	    label "[_ iurix-mail.Subject]"
	}
	from_address {
	    label "[_ iurix-mail.From]"
	}
	date {
	    label "[_ iurix-mail.Date]"
	}
    }



db_multirow -extend {} emails select_messages {
    SELECT mail_id, subject, from_address, date FROM iurix_mails WHERE user_id = :user_id

}