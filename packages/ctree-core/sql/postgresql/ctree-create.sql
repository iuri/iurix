-- /packages/ctree-core/sql/postgresql/ctree-create.sql



select content_type__create_type (
       'c_tree',    -- content_type
       'content_revision',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'C-Tree Object',    -- pretty_name
       'C-Tree Objects',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'c_tree__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'c_tree','t');


select content_type__create_type (
       'c_type',    -- content_type
       'c_tree',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'C-Tree Type',    -- pretty_name
       'C-Tree Types',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'c_type__get_title' -- name_method
);



-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'c_type','t');

-- "e19ce806-319b-cec9-dba2-16d7dcebd700" : {
-- "color" : "#16ad16",
-- "description" : "How to structure or accomplish suggestion",
-- "iconUrl" : "/images/app-icon-32.png",
-- "name" : "Implementation",
-- "parentTypes" : [ null, "e19ce806-319b-cec9-dba2-16d7dcebd700", "77ffc744-2142-c4cc-8366-35d4c3a6f23b", "8e4d0986-7fc1-fdde-a167-bcb905702193" ],
-- "parentsMax" : 1,
-- "parentsRequired" : true,
-- "prompt" : "Suggest implementation"
-- },


select content_type__create_type (
       'c_segmenttype',    -- content_type
       'c_tree',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'C-Tree Segment Type',    -- pretty_name
       'C-Tree Segment Types',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'c_segmenttype__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'c_segmenttype','t');



select content_type__create_type (
       'c_segmentvariation',     -- content_type
       'c_tree',       	 -- supertype. We search revision content 
                                 -- first, before item metadata
       'C-Tree Segment Variation',    -- pretty_name
       'C-Tree Segment Variations',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'c_segmentvariation__get_title' -- name_method
);






-- "elements" : {
--"2433fa24-3570-3e30-e032-03b81dd8ddcb" : {
--"childCount" : 1,
--"createdDate" : 123456789,
--"feedbackCount" : 1,
--"interactionCount" : 0,
--"lastInteractionDate" : 12345789,
--"rating" : 0,
--"title" : "test1",
--"type" : "21ec137f-d241-1062-535d-348db8190275"
--},


select content_type__create_type (
       'c_element',     -- content_type
       'c_tree',    	 -- supertype. We search revision content 
                        -- first, before item metadata
       'C-Tree Element',    -- pretty_name
       'C-Tree Elements',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'c_element__get_title' -- name_method
);
