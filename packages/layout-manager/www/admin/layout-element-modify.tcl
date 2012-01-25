
#
#  Copyright (C) 2001, 2002 MIT
#
#  This file is part of dotLRN.
#
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

ad_page_contract {

    Displays a configuration page for COMMUNITY'S portal ONLY!
    This page is restricted to admins of the community.

    User portals are configured by the configure.tcl page.

    @author Arjun Sanyal (arjun@openforce.net)
    @version $Id: one-community-portal-configure.tcl,v 1.9 2006/08/08 21:26:24 donb Exp $
} {
	element_id:integer
	sort_key:integer
	region:integer
}


ns_log Notice "PAGE layout-element-modify"


#prevent this page from being called when it is not allowed
# i.e.   AllowCustomizePortalLayout 0
#dotlrn_portlet::is_allowed -parameter cplayout

#set community_id [dotlrn_community::get_community_id]

#dotlrn::require_user_admin_community  -user_id [ad_conn user_id]  -community_id $community_id


# we are in a community
#portal::element_modify $region $sort_key $element_id




# iuri 2010-07-29
#find a analog API in layout-manager pkg. debug ::element_modify. analyze how is modify elements and compare how layout-manager modifies elements