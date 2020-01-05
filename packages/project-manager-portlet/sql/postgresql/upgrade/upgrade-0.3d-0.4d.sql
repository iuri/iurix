--
--  Copyright (C) 2001, 2002 MIT
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

--
-- /project-manager-project-calendarportlet/sql/oracle/project-manager-project-calendarportlet-create.sql
--

-- Creates Project Manager portlet

-- Copyright (C) 2005 Cognovis
-- @author Bjoern Kiesbye (kiesbye@theservice.de)
-- @creation-date 2005-08-06


-- This is free software distributed under the terms of the GNU Public
-- License version 2 or higher.  Full text of the license is available
-- from the GNU Project: http://www.fsf.org/copyleft/gpl.html

create function inline_0()
returns integer as '
declare
  ds_id portal_datasources.datasource_id%TYPE;
begin
  ds_id := portal_datasource__new(
         ''project_manager_project_calendar_portlet'',
         ''Displays the Project Manager''
  );

  
  --  the standard 4 params

  -- shadeable_p 
  perform portal_datasource__set_def_param (
	ds_id,
	''t'',
	''t'',
	''shadeable_p'',
	''t''
);	


  -- hideable_p 
  perform portal_datasource__set_def_param (
	ds_id,
	''t'',
	''t'',
	''hideable_p'',
	''t''
);	

  -- user_editable_p 
  perform portal_datasource__set_def_param (
	ds_id,
	''t'',
	''t'',
	''user_editable_p'',
	''t''
);	

  -- shaded_p 
  perform portal_datasource__set_def_param (
	ds_id,
	''t'',
	''t'',
	''shaded_p'',
	''f''
);	

  -- link_hideable_p 
  perform portal_datasource__set_def_param (
	ds_id,
	''t'',
	''t'',
	''link_hideable_p'',
	''t''
);	


    perform portal_datasource__set_def_param(
        ds_id,
        ''t'',
        ''f'',
        ''scoped_p'',
        ''t''
    );


  -- Project Manager Project Calendar Porltet specific params
  
  -- Project_manager_id must be configured 

     perform portal_datasource__set_def_param (
	 ds_id,
	 ''t'',
	 ''f'',
	 ''project_manager_id'',
	 ''''
      );




   return 0;

end;' language 'plpgsql';
select inline_0();
drop function inline_0();


create function inline_0()
returns integer as '
declare
	foo integer;
begin
	-- create the implementation
	foo := acs_sc_impl__new (
		''portal_datasource'',
		''project_manager_project_calendar_portlet'',
		''project_manager_project_calendar_portlet''
	);

   return 0;

end;' language 'plpgsql';
select inline_0();
drop function inline_0();



create function inline_0()
returns integer as '
declare
	foo integer;
begin

	-- add all the hooks
	foo := acs_sc_impl_alias__new (
	       ''portal_datasource'',
	       ''project_manager_project_calendar_portlet'',
	       ''GetMyName'',
	       ''project_manager_project_calendar_portlet::get_my_name'',
	       ''TCL''
	);

	foo := acs_sc_impl_alias__new (
	       ''portal_datasource'',
	       ''project_manager_project_calendar_portlet'',
	       ''GetPrettyName'',
	       ''project_manager_project_calendar_portlet::get_pretty_name'',
	       ''TCL''
	);

	foo := acs_sc_impl_alias__new (
	       ''portal_datasource'',
	       ''project_manager_project_calendar_portlet'',
	       ''Link'',
	       ''project_manager_project_calendar_portlet::link'',
	       ''TCL''
	);

	foo := acs_sc_impl_alias__new (
	       ''portal_datasource'',
	       ''project_manager_project_calendar_portlet'',
	       ''AddSelfToPage'',
	       ''project_manager_project_calendar_portlet::add_self_to_page'',
	       ''TCL''
	);

	foo := acs_sc_impl_alias__new (
	       ''portal_datasource'',
	       ''project_manager_project_calendar_portlet'',
	       ''Show'',
	       ''project_manager_project_calendar_portlet::show'',
	       ''TCL''
	);

	foo := acs_sc_impl_alias__new (
	       ''portal_datasource'',
	       ''project_manager_project_calendar_portlet'',
	       ''Edit'',
	       ''project_manager_project_calendar_portlet::edit'',
	       ''TCL''
	);

	foo := acs_sc_impl_alias__new (
	       ''portal_datasource'',
	       ''project_manager_project_calendar_portlet'',
	       ''RemoveSelfFromPage'',
	       ''project_manager_project_calendar_portlet::remove_self_from_page'',
	       ''TCL''
	);

   return 0;

end;' language 'plpgsql';
select inline_0();
drop function inline_0();



create function inline_0()
returns integer as '
declare
	foo integer;
begin

	-- Add the binding
	perform acs_sc_binding__new (
	    ''portal_datasource'',
	    ''project_manager_project_calendar_portlet''
	);

   return 0;

end;' language 'plpgsql';
select inline_0();
drop function inline_0();


