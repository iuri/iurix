# packages/project-manager/lib/portlet.tcl
#
# Portlet wrapper
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: c3461fd0-cb54-49bf-947a-8f710b3bd016
# @cvs-id $Id: portlet.tcl,v 1.1 2005/05/26 09:34:27 maltes Exp $

foreach required_param {portlet_title} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}
