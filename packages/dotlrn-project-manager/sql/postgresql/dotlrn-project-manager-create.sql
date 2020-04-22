--
--  Copyright (C) 2005 Cognovis
--
--  This file is part of dotLRN.
--
--  dotLRN is free software; you can redistribute it and/or modify it under the
--  terms of the GNU General Public License as published by the Free Software
--  Foundation; either version 2 of the License, or (at your option) any later
--  version.
--
--  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
--  details.
--

-- The dotlrn-project-manager applet's implimentation of the dotlrn applet contract
--
-- 
--
-- $Id: dotlrn-project-manager-create.sql
--

create function inline_0()
returns integer as '
declare
	foo integer;
begin
	-- create the implementation
	foo := acs_sc_impl__new (
		''dotlrn_applet'',
		''dotlrn_project_manager'',
		''dotlrn_project_manager''
	);

	-- GetPrettyName
	foo := acs_sc_impl_alias__new (
	       ''dotlrn_applet'',
	       ''dotlrn_project_manager'',
	       ''GetPrettyName'',
	       ''dotlrn_project_manager::get_pretty_name'',
	       ''TCL''
	);

	-- AddApplet
	foo := acs_sc_impl_alias__new (
	       ''dotlrn_applet'',
	       ''dotlrn_project_manager'',
	       ''AddApplet'',
	       ''dotlrn_project_manager::add_applet'',
	       ''TCL''
	);

	-- RemoveApplet
	foo := acs_sc_impl_alias__new (
	       ''dotlrn_applet'',
	       ''dotlrn_project_manager'',
	       ''RemoveApplet'',
	       ''dotlrn_project_manager::remove_applet'',
	       ''TCL''
	);

	-- AddAppletToCommunity
	foo := acs_sc_impl_alias__new (
	       ''dotlrn_applet'',
	       ''dotlrn_project_manager'',
	       ''AddAppletToCommunity'',
	       ''dotlrn_project_manager::add_applet_to_community'',
	       ''TCL''
	);

	-- RemoveAppletFromCommunity
	foo := acs_sc_impl_alias__new (
	       ''dotlrn_applet'',
	       ''dotlrn_project_manager'',
	       ''RemoveAppletFromCommunity'',
	       ''dotlrn_project_manager::remove_applet_from_community'',
	       ''TCL''
	);

	-- AddUser
	foo := acs_sc_impl_alias__new (
	       ''dotlrn_applet'',
	       ''dotlrn_project_manager'',
	       ''AddUser'',
	       ''dotlrn_project_manager::add_user'',
	       ''TCL''
	);

	-- RemoveUser
	foo := acs_sc_impl_alias__new (
	       ''dotlrn_applet'',
	       ''dotlrn_project_manager'',
	       ''RemoveUser'',
	       ''dotlrn_project_manager::remove_user'',
	       ''TCL''
	);

	-- AddUserToCommunity
	foo := acs_sc_impl_alias__new (
	       ''dotlrn_applet'',
	       ''dotlrn_project_manager'',
	       ''AddUserToCommunity'',
	       ''dotlrn_project_manager::add_user_to_community'',
	       ''TCL''
	);

	-- RemoveUserFromCommunity
	foo := acs_sc_impl_alias__new (
	       ''dotlrn_applet'',
	       ''dotlrn_project_manager'',
	       ''RemoveUserFromCommunity'',
	       ''dotlrn_project_manager::remove_user_from_community'',
	       ''TCL''
	);

    -- AddPortlet
    foo := acs_sc_impl_alias__new (
        ''dotlrn_applet'',
        ''dotlrn_project_manager'',
        ''AddPortlet'',
        ''dotlrn_project_manager::add_portlet'',
        ''TCL''
    );

    -- RemovePortlet
    foo := acs_sc_impl_alias__new (
        ''dotlrn_applet'',
        ''dotlrn_project_manager'',
        ''RemovePortlet'',
        ''dotlrn_project_manager::remove_portlet'',
        ''TCL''
    );

    -- Clone
    foo := acs_sc_impl_alias__new (
        ''dotlrn_applet'',
        ''dotlrn_project_manager'',
        ''Clone'',
        ''dotlrn_project_manager::clone'',
        ''TCL''
    );

    foo := acs_sc_impl_alias__new (
        ''dotlrn_applet'',
        ''dotlrn_project_manager'',
        ''ChangeEventHandler'',
        ''dotlrn_project_manager::change_event_handler'',
        ''TCL''
    );

	-- Add the binding
	perform acs_sc_binding__new (
	    ''dotlrn_applet'',
	    ''dotlrn_project_manager''
	);

	return 0;

end;' language 'plpgsql';
select inline_0();
drop function inline_0();
