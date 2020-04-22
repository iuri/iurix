-- 
-- 
-- 
-- @author Jade Rubick (jader@bread.com)
-- @creation-date 2004-06-24
-- @arch-tag: dac85e4c-c80a-4e17-b3ce-6ce34d9510c8
-- @cvs-id $Id: upgrade-1.08b1-1.09b1.sql,v 1.3 2005/05/26 09:34:28 maltes Exp $
--

alter table pm_process_task add column ordering integer;
