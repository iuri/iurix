-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2004-12-18
-- @cvs-id $Id: upgrade-0.4d1-0.4d2.sql,v 1.3 2018/08/15 16:53:10 gustafn Exp $
--

alter table txt drop constraint txt_object_id_fk;
alter table txt add constraint txt_object_id_fk foreign key (object_id) references acs_objects (object_id) on delete cascade;
