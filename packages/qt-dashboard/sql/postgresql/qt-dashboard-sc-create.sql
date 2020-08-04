-- Implement site-wide search using OpenFTS
--
--
-- qt-dashboard/sql/postgresql/qt-dashboard-sc-create.sql
--
-- @author Iuri de Araujo (iuri@iurix.com)
--

--Implement a content provider contract
-- content_type: qt_face
select acs_sc_impl__new(
           'FtsContentProvider',                -- impl_contract_name
           'qt_face',               		-- impl_name (the content_type created above)
           'qt-dashboard'                       -- impl_owner_name (package key of File Storage)
	   );

-- Implement an association with function 'datasource' and the concrete implementation 'fs__datasource'
select acs_sc_impl_alias__new(
           'FtsContentProvider',                -- impl_contract_name
           'qt_face',               		-- impl_name
           'datasource',                        -- impl_operation_name
           'qt_face__datasource',               -- impl_alias
           'TCL'                                -- impl_pl
);

-- Implement an association with function 'url' and the concrete implementation 'fs__url'
select acs_sc_impl_alias__new(
           'FtsContentProvider',                -- impl_contract_name
           'qt_face',               		-- impl_name
           'url',				-- impl_operation_name
           'qt_face__url',			-- impl_alias
           'TCL'                                -- impl_pl
);


select acs_sc_binding__new('FtsContentProvider','qt_face');




-- content_type: qt_vehicle
select acs_sc_impl__new(
           'FtsContentProvider',                -- impl_contract_name
           'qt_vehicle',               		-- impl_name (the content_type created above)
           'qt-dashboard'                       -- impl_owner_name (package key of File Storage)
	   );

-- Implement an association with function 'datasource' and the concrete implementation 'fs__datasource'
select acs_sc_impl_alias__new(
           'FtsContentProvider',                -- impl_contract_name
           'qt_vehicle',               		-- impl_name
           'datasource',                        -- impl_operation_name
           'qt_vehicle__datasource',               -- impl_alias
           'TCL'                                -- impl_pl
);

-- Implement an association with function 'url' and the concrete implementation 'fs__url'
select acs_sc_impl_alias__new(
           'FtsContentProvider',                -- impl_contract_name
           'qt_vehicle',               		-- impl_name
           'url',				-- impl_operation_name
           'qt_vehicle__url',			-- impl_alias
           'TCL'                                -- impl_pl
);


select acs_sc_binding__new('FtsContentProvider','qt_vehicle');

