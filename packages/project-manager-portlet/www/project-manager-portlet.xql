<?xml version="1.0"?>

<queryset>

<fullquery name="delete_item">
      <querytext>
        update na_items set deleted_p = '1' where item_id = :delete_id
      </querytext>
</fullquery>

<fullquery name="get_all_open_states">
      <querytext>
    select status_id
    from pm_project_status
    where status_type = 'o'
      </querytext>
</fullquery>

</queryset>
