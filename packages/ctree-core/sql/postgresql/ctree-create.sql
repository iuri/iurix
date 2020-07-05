-- /packages/ctree-core/sql/postgresql/ctree-create.sql
--
-- @author Iuri de Araujo (iuri@iurix.com)
-- @creation-date 5 July 2020
--


--
-- Type Definitions
--

--
-- ListDataKey (cTree, postType, segmentType, post, description, segmentVariation, feedback, query)
--

-- cTree
select content_type__create_type (
       'ctree',    -- content_type
       'content_revision',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'CTree Object',    -- pretty_name
       'CTree Objects',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'ctree__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'ctree','t');

--
-- types
--
-- The same as postTypes.
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
       'ctree_type',    -- content_type
       'ctree',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'CTree Type',    -- pretty_name
       'CTree Types',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'ctree_type__get_title' -- name_method
);



-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'ctree_type','t');

--
-- segmentTypes
--
select content_type__create_type (
       'ctree_segmenttype',    -- content_type
       'ctree',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'CTree Segment Type',    -- pretty_name
       'CTree Segment Types',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'ctree_segmenttype__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'ctree_segmenttype','t');


--
-- segmentVariations
--
-- forSegment {f07cd2c4-46d3-7516-ec91-f618ef539437 {42e4fc57-d485-6faf-d2ed-e5b4a4f65343 {data {test description 1} rating 0 type 9df0e7c6-89f9-ccd0-84ff-7d26dd589c8a}} 6a2f5405-4004-973b-0b83-2b4807b22016 {bc8dbc57-a087-99a4-9faa-51efd858e377 {data {test description 2} rating 0 type 9df0e7c6-89f9-ccd0-84ff-7d26dd589c8a}}}



select content_type__create_type (
       'ctree_segmentvariation',     -- content_type
       'ctree',       	 -- supertype. We search revision content 
                                 -- first, before item metadata
       'CTree Segment Variation',    -- pretty_name
       'CTree Segment Variations',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'ctree_segmentvariation__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'ctree_segmentvariation','t');



--
-- post
--
-- the same as elements
-- "post" : {
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
       'ctree_post',     -- content_type
       'ctree',    	 -- supertype. We search revision content 
                        -- first, before item metadata
       'CTree Post',    -- pretty_name
       'CTree Posts',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'ctree_post__get_title' -- name_method
);


-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'ctree_post','t');


--
-- descriptions
--
-- forElement {2433fa24-3570-3e30-e032-03b81dd8ddcb {246113fd-067a-f126-f406-3fea6605049f {rating 0 segments f07cd2c4-46d3-7516-ec91-f618ef539437}} bcd09662-a73f-93ce-56e5-930a6af3ef1a {b7aa416a-b185-2c05-709c-710b140440b0 {rating 0 segments 6a2f5405-4004-973b-0b83-2b4807b22016}}}
 

select content_type__create_type (
       'ctree_description',     -- content_type
       'ctree',    	 -- supertype. We search revision content 
                        -- first, before item metadata
       'CTree Description',    -- pretty_name
       'CTree Descriptions',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'ctree_description__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'ctree_description','t');



--
-- feedback
--
-- forDescription {246113fd-067a-f126-f406-3fea6605049f {18986a2d-7a73-8c4f-b4f1-110fe91bc45f {rating 0 text {test comment}}}}

select content_type__create_type (
       'ctree_feedback',     -- content_type
       'ctree',    	 -- supertype. We search revision content 
                        -- first, before item metadata
       'CTree Feedback',    -- pretty_name
       'CTree Feedbacks',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'ctree_feedback__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'ctree_feedback','t');
