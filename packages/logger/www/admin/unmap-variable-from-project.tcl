ad_page_contract {
    Unmap a variable from a logger project.
    
    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-05-01
    @cvs-id $Id: unmap-variable-from-project.tcl,v 1.2 2003/05/06 17:37:10 peterm Exp $
} {
    project_id:integer
    variable_id:integer
}

logger::project::unmap_variable -project_id $project_id -variable_id $variable_id

ad_returnredirect "project?project_id=$project_id"
