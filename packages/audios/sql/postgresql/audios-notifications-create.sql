
--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- @author iuri.sampaio@gmail.com
-- @creation-date 2010-10-19
--
-- This code is newly concocted by Ben, but with significant concepts and code
-- lifted from Gilbert's UBB forums. Thanks Orchard Labs.
--

-- the integration with Notifications

create function inline_0() returns integer as '
declare
        impl_id integer;
        v_foo   integer;
begin
        -- the notification type impl
        impl_id := acs_sc_impl__new (
                      ''NotificationType'',
                      ''audios_audio_notif_type'',
                      ''audios''
        );

        v_foo := acs_sc_impl_alias__new (
                    ''NotificationType'',
                    ''audios_audio_notif_type'',
                    ''GetURL'',
                    ''audios::notification::get_url'',
                    ''TCL''
        );

	v_foo := acs_sc_impl_alias__new (
                    ''NotificationType'',
                    ''audios_audio_notif_type'',
                    ''ProcessReply'',
                    ''audios::notification::process_reply'',
                    ''TCL''
        );	    


        PERFORM acs_sc_binding__new (
                    ''NotificationType'',
                    ''audios_audio_notif_type''
        );

        v_foo:= notification_type__new (
	        NULL,
                impl_id,
                ''audios_audio_notif'',
                ''Audio Notification'',
                ''Notifications for Entire Audios Application'',
		now(),
                NULL,
                NULL,
		NULL
        );

        -- enable the various intervals and delivery methods
        insert into notification_types_intervals
        (type_id, interval_id)
        select v_foo, interval_id
        from notification_intervals where name in (''instant'',''hourly'',''daily'');

        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select v_foo, delivery_method_id
        from notification_delivery_methods where short_name in (''email'');

        -- the notification type impl
        impl_id := acs_sc_impl__new (
                      ''NotificationType'',
                      ''audio_item_notif_type'',
                      ''audios''
                   );

        v_foo := acs_sc_impl_alias__new (
                    ''NotificationType'',
                    ''audio_item_notif_type'',
                    ''GetURL'',
                    ''audios::notification::get_url'',
                    ''TCL''
        );

        v_foo := acs_sc_impl_alias__new (
                    ''NotificationType'',
                    ''audio_item_notif_type'',
                    ''ProcessReply'',
                    ''audios::notification::process_reply'',
                    ''TCL''
        );

        PERFORM acs_sc_binding__new (
                    ''NotificationType'',
                    ''audio_item_notif_type''
        );

        v_foo:= notification_type__new (
		NULL,
                impl_id,
                ''audio_item_notif'',
                ''Audio Item Notification'',
                ''Notifications for Audio Item'',
		now(),
                NULL,
		NULL,
		NULL
        );

        -- enable the various intervals and delivery methods
        insert into notification_types_intervals
        (type_id, interval_id)
        select v_foo, interval_id
        from notification_intervals where name in (''instant'',''hourly'',''daily'');

        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select v_foo, delivery_method_id
        from notification_delivery_methods where short_name in (''email'');

	return (0);
end;
' language 'plpgsql';

select inline_0();
drop function inline_0();