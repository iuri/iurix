ad_page_contract {

} -query {
    {referer "group"}
    {orderby "name,asc"}
    {survey_id ""}
}

set spam_name [bulk_mail::parameter -parameter PrettyName -default [_ survey.Spam]]
set context_bar [list [list $referer [_ survey.Admin]] "$spam_name [_ survey.Group]"]

set package_id [ad_conn package_id]
set subsite_id [ad_conn subsite_id]
subsite::get -array subsite

ns_log Notice "$subsite_id | $package_id | $survey_id"
ns_log Notice "[parray subsite]"

db_1row select_group_id { 
    SELECT group_id FROM groups WHERE group_name = (select title from acs_objects WHERE object_type = 'application_group' AND context_id = :subsite_id)
   
}
ns_log Notice "GROUP ID $group_id"

set groups [db_list_of_lists select_groups {
    select group_id, group_name from groups
}]

set groups_html ""
ns_log Notice "GROUPS"
ns_log Notice "$groups"
foreach element $groups {
    ns_log Notice "$element"
    set group_id [lindex $element 0]
    set group_name [lindex $element 1]
    append groups_html "
<input type=checkbox value=$group_id name=group>$group_name<br>"
    
    
}

set exported_vars [export_vars -form { referer}]
# set group_id [group::get_id -group_name $subsite(instance_name) -subsite_id $subsite(node_id)]
#    set group_members [group::get_members -group_id $group_id]

template::list::create \
    -name current_members \
    -multirow current_members \
    -key user_id \
    -elements {
       user_id {
            display_template {
		<input type=checkbox value=@current_members.user_id;noquote@ name=recipients>
            }
       }
	name {
	    label "[_ survey.Name]"
	}
	email {
            label "[_ survey.Email]"
            html { style "width:200" }
            display_template {
                @current_members.email;noquote@
            }
        }
    } -orderby {
         name {
            label "[_ survey.Name]"
            orderby "lower(ru.first_names || ' ' || ru.last_name)"
        }
    }

db_multirow -extend { email } -unclobber current_members select_current_membes "
    SELECT ru.user_id,
    ru.first_names || ' ' || ru.last_name as name,
    ru.email
    FROM registered_users ru, group_member_map gmm
    WHERE ru.user_id = gmm.member_id
    AND gmm.group_id = :group_id
    [template::list::orderby_clause -orderby -name current_members]
    

" {
    set email [email_image::get_user_email -user_id $user_id]
}

ad_return_template
