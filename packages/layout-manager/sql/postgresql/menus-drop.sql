-- /packages/intranet/sql/oracle/intranet-menu-create.sql
--
-- Copyright (c) 2003-2008 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com
-- @author juanjoruizx@yahoo.es

---------------------------------------------------------
-- Menus
--
-- Dynamic Menus are necessary to allow modules
-- to extend the core at some point in the future without
-- that core would need know about these extensions in
-- advance.
--
-- Menus entries are basically mappings from a Name into a URL.
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

DROP FUNCTION layout_new_menu_perms (varchar, varchar);
DROP FUNCTION layout_new_menu (varchar, varchar, varchar, varchar, integer, varchar, varchar);
DROP FUNCTION layout_menu__name (integer);
DROP FUNCTION layout_menu__del_module (varchar);
DROP function layout_menu__delete (integer);
DROP FUNCTION layout_menu__new (integer, varchar, timestamptz, integer, varchar, integer,
varchar, varchar, varchar, varchar, integer, integer, varchar);

DELETE FROM acs_object_type_tables WHERE object_type = 'layout_menu' AND table_name =  'layout-menus' AND id_column = 'menu_id';

DROP TABLE layout_menus;

SELECT acs_object_type__drop_type ('layout_menu','t');



