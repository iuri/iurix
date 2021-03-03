-- /packages/qt-twilio/sql/postgresql/qt-twilio-create.sql
--
-- @author Iuri de Araujo (iuri@iurix.com)
-- @creation-date 21 March 2021
--

	       

--
-- WhatsApp Message
--
select content_type__create_type (
       'qt_whatsapp_msg',    -- content_type
       'content_revision',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'Qonteo WhatsApp Message',    -- pretty_name
       'Qonteo WhatsApp Messages',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'qt_whatsapp_msg__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'qt_whatsapp_msg','t');
