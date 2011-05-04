<?xml version="1.0"?>

<queryset>

    <fullquery name="select_members_user_id">
        <querytext>
	    select r.user_id as user_id
	    from registered_users r,
                 dotlrn_member_rels_approved
            where dotlrn_member_rels_approved.community_id = :community_id
            and dotlrn_member_rels_approved.user_id = r.user_id
        </querytext>
    </fullquery>

    <fullquery name="select_current_members">
        <querytext>
            select registered_users.first_names || ' ' || registered_users.last_name as name,
                   registered_users.email,
                   registered_users.user_id,
          (select ams_attribute_value__value(av.attribute_id,av.value_id) as value
            from ams_attribute_values av, ams_attributes aa
            where object_id = registered_users.user_id
                and av.attribute_id = aa.attribute_id
                and aa.attribute_name = 'country') as ams_country,
           (select ams_attribute_value__value(av.attribute_id,av.value_id) as value
            from ams_attribute_values av, ams_attributes aa
            where object_id = registered_users.user_id
                and av.attribute_id = aa.attribute_id
                and aa.attribute_name = 'org') as ams_org
            from registered_users,
                 dotlrn_member_rels_approved
            where dotlrn_member_rels_approved.community_id = :community_id
            and dotlrn_member_rels_approved.user_id = registered_users.user_id
           [template::list::orderby_clause -orderby -name "current_members"]
        </querytext>
    </fullquery>

</queryset>
