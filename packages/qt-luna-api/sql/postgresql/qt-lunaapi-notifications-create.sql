-- /packages/qt-lunaapi-notifications-create/sql/postgresql/qt-dashboard-create.sql
--
-- @author Iuri de Araujo (iuri@iurix.com)
-- @creation-date 27 January 2021
--



-- Creates a notification type qt_matching
CREATE FUNCTION inline_0() RETURNS integer AS $$
DECLARE
        impl_id integer;
        v_foo  integer;
BEGIN
        -- the notification type impl
        impl_id := acs_sc_impl__new (
                      'NotificationType',
                      'qt_face_matching_notif_type',
                      'qt_luna_api',
		      'qt_luna_api'
        );

        v_foo := acs_sc_impl_alias__new (
                    'NotificationType',
                    'qt_face_matching_notif_type',
                    'GetURL',
                    'qt_face_matching::notification::get_url',
                    'TCL'
        );

        v_foo := acs_sc_impl_alias__new (
                    'NotificationType',
                    'qt_face_matching_notif_type',
                    'ProcessReply',
                    'qt_face_matching::notification::process_reply',
                    'TCL'
        );

        PERFORM acs_sc_binding__new (
                    'NotificationType',
                    'qt_face_matching_notif_type'
        );

        v_foo:= notification_type__new (
            NULL,
                impl_id,
                'qt_face_matching_notif',
                'New Face Matching Notification',
                'Notifications for Face Mmatching added to the matching system',
        	now(),
                NULL,
                NULL,
        	NULL
        );

        -- enable the various intervals and delivery methods
        insert into notification_types_intervals
        (type_id, interval_id)
        select v_foo, interval_id
        from notification_intervals where name in ('instant','hourly','daily');

        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select v_foo, delivery_method_id
        from notification_delivery_methods where short_name in ('email');

	return (0);
END;
$$ language plpgsql;

select inline_0();
drop function inline_0();
