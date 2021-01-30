<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>


<if @admin_p@ ne nil>
  <a href="@admin_url@">@admin_title@</a>
  </if>



<include src="/packages/notifications/lib/notification-widget" type="qt_face_matching_notif" object_id="@package_id;literal@" pretty_name="@package_name;literal@" url="@package_url;literal@" >
