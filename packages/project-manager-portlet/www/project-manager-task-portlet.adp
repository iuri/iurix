<include src="@tasks_portlet@" 
	party_id="@filter_party_id@" 
	filter_group_id="@filter_group_id@" 
	base_url="@base_url@" 
	instance_id="@pm_package_id@"
	display_mode="list" 
	fmt="@fmt@" 
	elements="@elements@" 
	watcher_p="@watcher_p@" 
	page_num="@page_num@" 
	is_observer_filter="@is_observer_filter@"
	status_id="1"
	orderby_p="1"
        tasks_orderby="@tasks_orderby@"
	bulk_actions_p="1"
	tasks_portlet_p="t">

<br>
<if @is_observer_filter@ eq m and @filter_group_id@ ne @group_id@><font color=green>#project-manager-portlet.all_tasks#</font></if>
<else><a href="?" class="button">#project-manager-portlet.all_tasks#</a></else> |
<if @is_observer_filter@ eq f><font color=green>#project-manager-portlet.my_tasks#</font></if>
<else><a href="?page_num=@page_num@&is_observer_filter=f&filter_party_id=@user_id@" class="button">#project-manager-portlet.my_tasks#</a></else> |
<if @is_observer_filter@ eq t><font color=green>#project-manager-portlet.pool_tasks#</font></if>
<else><a href="?page_num=@page_num@&is_observer_filter=t" class="button">#project-manager-portlet.pool_tasks#</a></else> |
<if @filter_group_id@ eq @group_id@><font color=green>#project-manager-portlet.group_tasks#</font></if>
<else><a href="?page_num=@page_num@&is_observer_filter=&filter_group_id=@group_id@" class="button">#project-manager-portlet.group_tasks#</a></else>
<br><br>
