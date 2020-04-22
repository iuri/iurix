<?xml version="1.0"?>

<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="dotlrn_project_manager::clone.call_project_manager_clone">
  <querytext>
    select project_manager__clone ( 
        :old_package_id,
        :new_package_id
      );
  </querytext>
</fullquery>

<fullquery name="dotlrn_project_manager::upgrade.get_portal_templates">
  <querytext>
	select 
		portal_id 
	from 
		portals 
	where 
		name in ('#dotlrn.subcommunities_pretty_plural# Portal','#dotlrn.class_instance_portal_pretty_name# Portal','#dotlrn.clubs_pretty_plural# Portal') 
		and template_id is null;
  </querytext>
</fullquery>

<fullquery name="dotlrn_project_manager::upgrade.get_all_portal_templates">
  <querytext>
	select 
		portal_id 
	from 
		portals 
	where 
		name in ('#dotlrn.subcommunities_pretty_plural# Portal','#dotlrn.class_instance_portal_pretty_name# Portal','#dotlrn.clubs_pretty_plural# Portal','#dotlrn.user_portal_pretty_name# Portal') 
		and template_id is null;
  </querytext>
</fullquery>

</queryset>
