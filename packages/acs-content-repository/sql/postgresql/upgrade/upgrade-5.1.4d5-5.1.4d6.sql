-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2005-01-06
-- @cvs-id $Id: upgrade-5.1.4d5-5.1.4d6.sql,v 1.3 2018/08/15 16:48:01 gustafn Exp $
--


select define_function_args('content_template__new','name,parent_id,template_id,creation_date;now,creation_user,creation_ip,text,is_live;f');
