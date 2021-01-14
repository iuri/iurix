-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2005-01-06
-- @cvs-id $Id: upgrade-5.1.4d6-5.1.4d7.sql,v 1.3 2018/08/15 16:48:01 gustafn Exp $
--

select define_function_args('content_item__set_live_revision','revision_id,publish_status;ready');
