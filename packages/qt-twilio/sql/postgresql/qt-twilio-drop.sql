-- /packages/qt-twilio/sql/postgresql/qt-twilio-drop.sql
--
-- @author Iuri de Araujo (iuri@iurix.com)
-- @creation-date 21 March 2021
--

	       

--
-- WhatsApp Message
--
select content_folder__unregister_content_type(-100,'qt_whatsapp_msg','t');
select content_type__drop_type('qt_whatsapp_msg', 't', 't');

