-- packages/project-manager/sql/project-manager-drop.sql
-- drop script
--
-- @author jade@bread.com
-- @creation-date 2003-12-05
-- @cvs-id $Id: project-manager-custom-drop.sql,v 1.3 2005/05/26 09:34:28 maltes Exp $
--

-- drop any custom tables here.

select content_type__drop_attribute ('pm_project', 'customer_id', 't');

