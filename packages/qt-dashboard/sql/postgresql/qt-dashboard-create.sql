-- /packages/qt-dashboard/sql/postgresql/qt-dashboard-create.sql
--
-- @author Iuri de Araujo (iuri@iurix.com)
-- @creation-date 13 July 2020
--


-- Create custom sort function 
CREATE OR REPLACE FUNCTION custom_sort(anyarray, anyelement)
RETURNS integer AS  $$
BEGIN
    SELECT i FROM (
      SELECT generate_series(array_lower($1,1),array_upper($1,1))
    ) g(i)
    WHERE $1[i] = $2
    LIMIT 1;
$$ LANGUAGE plpgsql;
	       

--
-- Faces
--
select content_type__create_type (
       'qt_face',    -- content_type
       'content_revision',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'Qonteo Face',    -- pretty_name
       'Qonteo Faces',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'qt_face__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'qt_face','t');


--
-- Vehicles
--
select content_type__create_type (
       'qt_vehicle',    -- content_type
       'content_revision',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'Qonteo Vehicle',    -- pretty_name
       'Qonteo Vehicles',   -- pretty_plural
       qt_vehicles,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       qt_vehicle_id,	         -- id_column
       'qt_vehicle__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'qt_vehicle','t');


-- id 323659 plate_number IWR425 country_name Colombia country_symbol CO first_seen {2020-09-06 12:46:57} last_seen {2020-09-06 12:46:58} probability 1 location_name Test camera_name {LPR 3} direction COMING car_class Car plate_image http://178.62.211.78/plate_image_fa.php?id=323659 car_image http://178.62.211.78/car_image_fa.php?id=323659
-- id 138232 plate_number UNKNOWN country_name Unknown country_symbol ?? first_seen {2020-08-01 17:58:53} last_seen {2020-08-01 17:58:53} probability 0.2 location_name Test camera_name LPR3 direction UNKNOWN class UNKNOWN plate_image http://178.62.211.78/plate_image_fa.php?id=138232 car_image http://178.62.211.78/car_image_fa.php?id=138232
-- id 323666 plate_number WPP533 country_name Colombia country_symbol CO first_seen {2020-09-06 12:48:36} last_seen {2020-09-06 12:48:36} probability 0.4 location_name Test camera_name {LPR 3} direction COMING car_class Car plate_image http://178.62.211.78/plate_image_fa.php?id=323666 car_image http://178.62.211.78/car_image_fa.php?id=323666


-- SELECT cr.description FROM cr_items ci, acs_objects o, cr_revisions cr WHERE ci.item_id = o.object_id AND ci.item_id = cr.item_id AND ci.latest_revision = cr.revision_id AND ci.content_type = 'qt_vehicle' AND split_part(cr.description, ' ', 24) = 'car_class';

-- SELECT cr.description FROM cr_items ci, acs_objects o, cr_revisions cr WHERE ci.item_id = o.object_id AND ci.item_id = cr.item_id AND ci.latest_revision = cr.revision_id AND ci.content_type = 'qt_vehicle' AND split_part(cr.description, ' ', 23) = 'class';

---------
-- qt_vehicles
---------
create table ee_items (
    qt_vehicle_id	        integer
    				constraint qt_vehicle_id_fk
    				references cr_revisions on delete cascade
    				constraint qt_vehicle_id_pk primary key,
    metrici_id	      		integer,
    plate			varchar(10),
    car_image_url	      	varchar,
    plate_image_url         	varchar,
    country_iso			char(2),
    first_seen			timestamptz,
    last_seen			timestamptz,
    probability			numeric,
    category_id			integer
    				constraint category_id_fk
    				references categories
);

-- create content type attributes
select content_type__create_attribute (
  'qt_vehicle',			     -- content_type
  'metrici_id',		     	     -- attribute_name
  'integer',		    	     -- datatype
  'Metrici ID',		     	     -- pretty_name
  'Metrici IDs',	    	     -- pretty_plural
  null,			   	     -- sort_order
  null,			   	     -- default_value
  'integer'		    	     -- column_spec
);

-- create content type attributes
select content_type__create_attribute (
  'qt_vehicle',			     -- content_type
  'plate',		     	     -- attribute_name
  'text',		    	     -- datatype
  'Plate',		     	     -- pretty_name
  'Plates',	    	     	     -- pretty_plural
  null,			   	     -- sort_order
  null,			   	     -- default_value
  'text'		    	     -- column_spec
);


-- create content type attributes
select content_type__create_attribute (
  'qt_vehicle',			     -- content_type
  'car_image_url',		     -- attribute_name
  'text',		    	     -- datatype
  'Car Image URL',     	     	     -- pretty_name
  'Car Image URLs',    	     	     -- pretty_plural
  null,			   	     -- sort_order
  null,			   	     -- default_value
  'text'		    	     -- column_spec
);

-- create content type attributes
select content_type__create_attribute (
  'qt_vehicle',			     -- content_type
  'plate_image_url',	     	     -- attribute_name
  'text',		    	     -- datatype
  'Plate Image URL',	     	     -- pretty_name
  'Plate Image URLs',    	     -- pretty_plural
  null,			   	     -- sort_order
  null,			   	     -- default_value
  'text'		    	     -- column_spec
);

-- create content type attributes
select content_type__create_attribute (
  'qt_vehicle',			     -- content_type
  'country_iso',	     	     -- attribute_name
  'text',		    	     -- datatype
  'Country ISO',	     	     -- pretty_name
  'Country ISOs',    	     	     -- pretty_plural
  null,			   	     -- sort_order
  null,			   	     -- default_value
  'text'		    	     -- column_spec
);

-- create content type attributes
select content_type__create_attribute (
  'qt_vehicle',			     -- content_type
  'first_seen',		     	     -- attribute_name
  'timestamptz',	    	     -- datatype
  'First Seen',		     	     -- pretty_name
  'First Seen',	    	     	     -- pretty_plural
  null,			   	     -- sort_order
  null,			   	     -- default_value
  'timestamptz'		    	     -- column_spec
);


-- create content type attributes
select content_type__create_attribute (
  'qt_vehicle',			     -- content_type
  'last_seen',		     	     -- attribute_name
  'timestamptz',	    	     -- datatype
  'Last Seen',		     	     -- pretty_name
  'Last Seen',	    	     	     -- pretty_plural
  null,			   	     -- sort_order
  null,			   	     -- default_value
  'timestamptz'		    	     -- column_spec
);
