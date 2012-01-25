-- drop layout pagesets datamodel
--
-- @author Don Baccus (dhogaza@pacifier)
-- @creation-date 2008-07-05
-- @version $Id: pagesets-drop.sql,v 1.1.1.1 2008/07/22 07:31:02 donb Exp $
--

begin
acs_rel_type.drop_type('layout_pageset');
end;
/
show errors

drop table layout_pagesets;
