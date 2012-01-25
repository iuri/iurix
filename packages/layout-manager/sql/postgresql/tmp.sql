create or replace function layout_menu__new (integer, varchar, timestamptz, integer, varchar, integer, varchar, integer, varchar, varchar, varchar, integer, integer, varchar) returns integer as '
declare 
        p_menu_id               alias for $1;   -- default null
	p_object_type           alias for $2;   -- default acs_object
	p_creation_date         alias for $3;   -- default now()
	p_creation_user         alias for $4;   -- default null
	p_creation_ip           alias for $5;   -- default null
	p_context_id            alias for $6;   -- default null
	p_package_name          alias for $7;
	p_package_id            alias for $8;
	p_label                 alias for $9;
	p_name                  alias for $10;
	p_url                   alias for $11;
	p_sort_order            alias for $12;
	p_parent_menu_id        alias for $13;
	p_visible_tcl           alias for $14;  -- default null
	
	v_menu_id               layout_menus.menu_id%TYPE;

begin                                                                                                                                                        
        select  menu_id into v_menu_id
	from    layout_menus m where m.label = p_label;
	IF v_menu_id is not null THEN return v_menu_id; END IF;

	v_menu_id := acs_object__new (
		  p_menu_id,              -- object_id
		  p_object_type,          -- object_type
		  p_creation_date,        -- creation_date
		  p_creation_user,        -- creation_user 
		  p_creation_ip,          -- creation_ip
		  p_context_id,           -- context_id
		  ''t'',		  -- security_inherit_p
		  null,			  -- title
		  p_package_id		  -- package_id
	);

        insert into layout_menus (menu_id, package_name, label, name, url, sort_order, parent_menu_id, visible_tcl) 
	values (v_menu_id, p_package_name, p_label, p_name, p_url, p_sort_order, p_parent_menu_id, p_visible_tcl);

return v_menu_id;                                                                                                                                    
end;' language 'plpgsql';