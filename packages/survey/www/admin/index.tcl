# /www/survey/admin/index.tcl
ad_page_contract {
    This page is the main table of contents for navigation page 
    for simple survey module administrator

    @author philg@mit.edu
    @author nstrug@arsdigita.com
    @date 3rd October, 2000
    @cvs-id $Id: index.tcl,v 1.2 2005/01/21 17:24:28 jeffd Exp $
} {

}

set package_id [ad_conn package_id]
set return_url [ad_return_url]
# bounce the user if they don't have permission to admin surveys
ad_require_permission $package_id survey_admin_survey

set disabled_header_written_p 0

set survey_create_p [permission::permission_p -object_id $package_id -privilege survey_create]
set survey_delete_p [permission::permission_p -object_id $package_id -privilege surveydelete]

set admin_p [permission::permission_p -object_id $package_id -privilege admin]

set actions [list]
set bulk_actions [list]
 
if {$admin_p} {
    lappend actions "#survey.New_Survey#" survey-create "#survey.Create_a_new_survey#"
    
    lappend bulk_actions "#survey.Delete#" survey-bulk-delete "#survey.Delete_selected_surveys#"
}

template::list::create \
    -name surveys \
    -multirow surveys \
    -key survey_id \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars { return_url } \
    -elements {
	active {
	    label "#survey.Status#"
	    html { style "text-align: center" }
	    display_template {
		<if @surveys.enabled_p@ eq t>
		<a href="survey-toggle?enabled_p=t&survey_id=@surveys.survey_id@&target=.">
                <img src="/resources/survey/active.png" alt="#survey.Survey_active#"></a>
                </if>
                <else>
		<a href="survey-toggle?enabled_p=f&survey_id=@surveys.survey_id@&target=.">
                <img src="/resources/survey/inactive.png" alt="#survey.Survey_no_active#"></a>
                </else>
	    }
	}
	name {
	    label "#survey.Survey_name#"
	    display_template {
                <if @surveys.enabled_p@ eq t>
		<a href=one?survey_id=@surveys.survey_id@>@surveys.name@</a> 
		</if>
                <else>
                @surveys.name@
                </else>
            }
        }	
    }
db_multirow surveys select_surveys {}
ad_return_template
