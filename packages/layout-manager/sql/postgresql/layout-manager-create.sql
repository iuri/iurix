-- create the layout manager datamodel
--
-- @author Don Baccus (dhogaza@pacifier.com)
-- @creation-date 2001-10-01
-- @version $Id: layout-manager-create.sql,v 1.2 2008/07/30 11:59:33 donb Exp $
--

create sequence layout_seq;

\i includelets-create.sql
\i page-templates-create.sql
\i themes-create.sql
\i pagesets-create.sql
\i pages-create.sql
\i elements-create.sql
\i menus-create.sql