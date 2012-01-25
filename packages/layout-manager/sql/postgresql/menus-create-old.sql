-- /packages/intranet/sql/oracle/intranet-menu-create.sql
--
-- Copyright (c) 2003-2004 Project/Open
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com
-- @author juanjoruizx@yahoo.es

---------------------------------------------------------
-- Menus
--
-- Dynamic Menus are necessary to allow Project/Open modules
-- to extend the core at some point in the future without
-- that core would need know about these extensions in
-- advance.
--
-- Menus entries are basicly mappings from a Name into a URL.
--
-- In addition, menu entries contain a parent_menu_id,
-- allowing for a tree view of all menus (to build a left-
-- hand-side navigation bar).
--
-- The same parent_menu_id field allows a particular page 
-- to find out about its submenus items to display by checking 
-- the super-menu that points to the page and by selecting
-- all of its sub-menu-items. However, the develpers needs to
-- avoid multiple menu pointers to the same page because
-- this leads to an ambiguity about the supermenu.
-- These ambiguities are resolved by taking the menu from
-- the highest possible hierarchy level and then using the
-- lowest sort_key.

BEGIN;

SELECT acs_object_type__create_type (
        'menu',				        -- object_type
        'ACS Menu',					    -- pretty_name
        'ACS Menus',		    		-- pretty_plural
        'acs_object',		        -- supertype
        'menus',					-- table_name
        'menu_id',		    		-- id_column
        'acs_subsite_menu',		    -- package_name
        'f',                        -- abstract_p
        null,                       -- type_extension_table
        'menus.name'  				-- name_method
    );


-- The idea is to use OpenACS permissions in the future to
-- control who should see what menu.

CREATE TABLE menus (
	menu_id 	integer
				constraint menu_id_pk
				primary key
				constraint menu_id_fk
        		references acs_objects,
				-- used to remove all menus from one package
				-- when uninstalling a package
	package_name		varchar(200) not null,
				-- symbolic name of the menu that cannot be
				-- changed using the menu editor.
				-- It cat be used as a constant by TCL pages to
				-- locate their menus.
	label			varchar(200) not null,
				-- the name that should appear on the tab
	name			varchar(200) not null,
				-- On which pages should the menu appear?
	url			varchar(200) not null,
				-- sort order WITHIN the same level
	sort_order		integer,
				-- parent_id allows for tree view for navbars
	parent_menu_id		integer
				constraint menus_parent_menu_id_fk
				references menus,	
				-- hierarchical codification of menu levels
	tree_sortkey		varchar(100),
				-- TCL expression that needs to be either null
				-- or evaluate (expr *) to 1 in order to display 
				-- the menu.
	visible_tcl		varchar(1000) default null,
				-- Make sure there are no two identical
				-- menus on the same _level_.
	constraint menus_label_un
	unique(label)
);

create or replace function menu__new (integer, varchar, timestamptz, integer, varchar, integer,
varchar, varchar, varchar, varchar, integer, integer, varchar) returns integer as '
declare
	p_menu_id	      alias for $1;   -- default null
    	p_object_type	  alias for $2;   -- default ''acs_object''
   	p_creation_date	  alias for $3;   -- default now()
    	p_creation_user	  alias for $4;   -- default null
    	p_creation_ip	  alias for $5;   -- default null
    	p_context_id	  alias for $6;   -- default null
    	p_package_name	  alias for $7;   
	p_label		      alias for $8;
	p_name		      alias for $9;
	p_url		      alias for $10;
	p_sort_order	  alias for $11;
	p_parent_menu_id  alias for $12;
	p_visible_tcl	  alias for $13;  -- default null

	v_menu_id	  menus.menu_id%TYPE;
begin
	v_menu_id := acs_object__new (
                p_menu_id,          -- object_id
                p_object_type,      -- object_type
                p_creation_date,    -- creation_date
                p_creation_user,    -- creation_user
                p_creation_ip,      -- creation_ip
                p_context_id,       -- context_id
		''t'',
	        p_name,             -- title
	        p_context_id        -- package_id
        );

	insert into menus (
		menu_id, package_name, label, name, 
		url, sort_order, parent_menu_id, visible_tcl
	) values (
		v_menu_id, p_package_name, p_label, p_name, p_url, 
		p_sort_order, p_parent_menu_id, p_visible_tcl
	);
	return v_menu_id;
end;' language 'plpgsql';


-- Delete a single menu (if we know its ID...)
-- Delete a single component
create or replace function menus__delete (integer) returns integer as '
DECLARE
	p_menu_id	alias for $1;
BEGIN
	-- Erase the menus item associated with the id
	delete from 	menus
	where		menu_id = p_menu_id;

	-- Erase all the priviledges
	delete from 	acs_permissions
	where		object_id = p_menu_id;
	
	PERFORM acs_object__delete(p_menu_id);
        return 0;
end;' language 'plpgsql';


-- Delete all menus of a instantiated package.
-- Used in <module-name>-drop.sql
create or replace function menus__del_module (integer) returns integer as '
DECLARE
	p_package_id   alias for $1;
    row            RECORD;
BEGIN
     -- First we have to delete the references to parent menus...
     for row in 
        select menu_id
        from menus
        where package_name = p_module_name
     loop

	update menus 
	set parent_menu_id = null
	where menu_id = row.menu_id;

     end loop;

     -- ... then we can delete the menus themseves
     for row in 
        select menu_id
        from menus
        where package_name = p_module_name
     loop

	PERFORM menus__delete(row.menu_id);

     end loop;

     return 0;
end;' language 'plpgsql';


-- Returns the name of the menu
create or replace function menus__name (integer) returns varchar as '
DECLARE
    p_menu_id   alias for $1;
	v_name	    menus.name%TYPE;
BEGIN
	select	name
	into	v_name
	from	menus
	where	menu_id = p_menu_id;

	return v_name;
end;' language 'plpgsql';


create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_top_menu		integer;

	-- Groups
	v_public		integer;
begin

    select group_id into v_public from groups where group_name = ''#acs-kernel.The_Public#'';


    -- The top menu - the father of all menus.
    -- It is not displayed itself and only serves
    -- as a parent_menu_id from ''main'' and ''survey''.


    v_top_menu := menu__new (
	null,                   -- p_menu_id
        ''acs_object'',         -- object_type
        now(),                  -- creation_date
        null,                   -- creation_user
        null,                   -- creation_ip
        null,                   -- context_id
	''acs-subsite'',        -- package_name for Main Subsite
	''Top Menu'',		-- label
	''top'',	     	-- name
	''/'',		        -- url
	10,	       		-- sort_order
	null,			-- parent_menu_id
	null			-- p_visible_tcl
    );

    PERFORM acs_permission__grant_permission(v_top_menu, v_public, ''read'');

 return 0;

end;' language 'plpgsql';

select inline_0 ();

drop function inline_0 ();



COMMIT;

