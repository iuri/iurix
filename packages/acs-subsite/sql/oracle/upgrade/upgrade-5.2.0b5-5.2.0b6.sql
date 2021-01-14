-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2005-11-29
-- @cvs-id $Id: upgrade-5.2.0b5-5.2.0b6.sql,v 1.3 2018/08/15 16:48:01 gustafn Exp $
--


alter table site_nodes_selection drop constraint site_nodes_sel_id_fk;
alter table site_nodes_selection add constraint site_nodes_sel_id_fk foreign key (node_id) references acs_objects(object_id) on delete cascade;
