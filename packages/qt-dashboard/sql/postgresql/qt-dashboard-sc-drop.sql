-- Drop site-wide search using OpenFTS
--
-- qt-dashboard/sql/postgresql/qt-dashboard-sc-drop.sql
--
-- @author Iuri de Araujo (iuri@iurix.com)
--

--content_type: qt_face
-- Drop association with function 'datasource' and their concrete implementation 'qt_dashboard__datasource'
select acs_sc_impl_alias__delete(
           'FtsContentProvider',                -- impl_contract_name
           'qt_face',                 		-- impl_name
           'datasource'                         -- impl_operation_name
);

-- Drop association with function 'url' and their concrete implementation 'qt_dashboard__url'
select acs_sc_impl_alias__delete(
           'FtsContentProvider',		-- impl_contract_name
           'qt_face',               		-- impl_name
           'url'				-- impl_operation_name
);

-- Drop the search contract implementation
select acs_sc_impl__delete(
           'FtsContentProvider',                -- impl_contract_name
           'qt_dashboard'                	-- impl_name (the content_type created above)
);





-- content_type: qt_vehicle
-- Drop association with function 'datasource' and their concrete implementation 'qt_dashboard__datasource'
select acs_sc_impl_alias__delete(
           'FtsContentProvider',                -- impl_contract_name
           'qt_vehicle',                 		-- impl_name
           'datasource'                         -- impl_operation_name
);

-- Drop association with function 'url' and their concrete implementation 'qt_dashboard__url'
select acs_sc_impl_alias__delete(
           'FtsContentProvider',		-- impl_contract_name
           'qt_vehicle',               		-- impl_name
           'url'				-- impl_operation_name
);

-- Drop the search contract implementation
select acs_sc_impl__delete(
           'FtsContentProvider',                -- impl_contract_name
           'qt_dashboard'                	-- impl_name (the content_type created above)
);

