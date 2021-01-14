-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2005-01-06
-- @cvs-id $Id: upgrade-5.2.0d10-5.2.0d11.sql,v 1.2 2018/08/15 16:48:01 gustafn Exp $
--

select define_function_args('content_template__new','name,parent_id,template_id,creation_date;now,creation_user,creation_ip,text,is_live;f');
