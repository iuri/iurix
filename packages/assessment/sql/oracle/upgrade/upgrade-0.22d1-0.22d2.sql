-- 
-- packages/assessment/sql/postgresql/upgrade/upgrade-0.22d1-0.22d2.sql
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2006-10-16
-- @cvs-id $Id: upgrade-0.22d1-0.22d2.sql,v 1.1 2006/10/16 13:20:44 daveb Exp $
--

create index as_item_data_as_item_id_idx on as_item_data (as_item_id);
