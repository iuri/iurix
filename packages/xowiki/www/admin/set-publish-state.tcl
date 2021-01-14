::xowiki::Package initialize -ad_doc {
  Changes the publication state of a content item

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at)
  @creation-date Nov 16, 2006
  @cvs-id $Id: set-publish-state.tcl,v 1.16 2019/01/27 17:07:55 gustafn Exp $

  @param object_type
  @param query
} -parameter {
  {-state:required}
  {-revision_id:integer,required}
  {-return_url "."}
}

set page [::xo::db::CrClass get_instance_from_db -revision_id $revision_id]
$page update_publish_status $state

ad_returnredirect $return_url
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 2
#    indent-tabs-mode: nil
# End:
