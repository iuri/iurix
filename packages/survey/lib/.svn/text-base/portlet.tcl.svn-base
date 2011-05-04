# include fragment to display the active surveys in a package
#
# @author Tom Ayles (tom@beatniq.net)
# @creation-date 2004-02-17
# @cvs-id $Id: portlet.tcl,v 1.1 2005/01/21 17:24:28 jeffd Exp $
#
# parameters:
#  package_id - the ID of the surveys package to query
#  base_url - the base URL of the package
#  display_empty_p - if true, display when empty (default 1)
#  class - CSS CLASS attribute value
#  id - CSS ID attribute value
#  cache - cache period, default 0 meaning no cache

if { ![exists_and_not_null package_id]
     && ![exists_and_not_null base_url] } {
    error "must specify package_id and/or base_url"
}

if { ![exists_and_not_null cache] } {
    set cache 0
}

if { ![exists_and_not_null display_empty_p] } {
    set display_empty_p 1
}

if { ![exists_and_not_null id] } {
    set id "survey"
	# If CSS is not supplid, we use the standard
	template::head::add_style -style {
		#survey {
			margin-right: 10px;
		}
		#survey li {
			list-style-type: none;
			margin-left: -40px;
		}
	}
}

if { ![exists_and_not_null class] } {
    set class ""
}

if { ![exists_and_not_null base_url] } {
    set base_url [lindex [site_node::get_url_from_object_id \
                              -object_id $package_id] 0]
}
if { ![exists_and_not_null package_id] } {
    set package_id [site_node::get_element \
                        -url $base_url -element object_id]
}
set package_name [apm_instance_name_from_id $package_id]

set script "# /packages/survey/lib/portlet.tcl
db_list_of_lists ls {} -bind { package_id $package_id }"

multirow create active survey_id name url base_url

foreach row [util_memoize $script $cache] {
    set survey_id [lindex $row 0]
    set name [lindex $row 1]
    set url "${base_url}respond?survey_id=$survey_id"

    multirow append active $survey_id $name $url $base_url
}

ad_return_template
