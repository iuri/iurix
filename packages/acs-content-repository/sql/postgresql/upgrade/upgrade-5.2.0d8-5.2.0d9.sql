-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2004-12-29
-- @cvs-id $Id: upgrade-5.2.0d8-5.2.0d9.sql,v 1.2 2018/08/15 16:48:01 gustafn Exp $
--
-- set default for creation_date

select define_function_args('content_template__new','name,parent_id,template_id,creation_date;now,creation_user,creation_ip');
