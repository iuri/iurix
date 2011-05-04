ad_page_contract {
  Remove audio by audio_id

    @author iuri sampaio
    @date 2010-12-06
} {
	audio_id
}


permission::require_permission -party_id [ad_conn user_id] -object_id $audio_id -privilege admin

ad_form -export {audio_id} -name audio-delete -form {
	{confirm:text(radio)
		{label "[_ audios.Confirme_remove_Audios]"} 
		{options {
				{"[_ audios.No]" "0"} 
				{"[_ audios.Yes]" "1"}}
		}
	}
} -on_submit {
	
	set message1 "[_ audios.Audio_dont_removed]"
	if {$confirm == 1} {
		db_exec_plsql remove_audio { select audio__delete(:audio_id)}
		set message1 "[_ audios.Audio_removed]"
	}
	
	ad_returnredirect -message $message1 "."
        ad_script_abort
}
