-- create the layout manager datamodel
--
-- @author Don Baccus (dhogaza@pacifier.com)
-- @creation-date 2008-07-11
-- @version $Id: layout-manager-create.sql,v 1.1.1.1 2008/07/22 07:31:02 donb Exp $
--

create sequence layout_seq;

@@includelets-create
@@page-templates-create
@@themes-create
@@pagesets-create
@@pages-create
@@pageset-package-create
@@elements-create
