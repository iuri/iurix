<?xml version="1.0"?>
<queryset>
  <fullquery name="get_today">
    <querytext>
        select to_date(current_timestamp,'YYYY-MM-DD HH24:MI') from dual;
    </querytext>
  </fullquery>

  <fullquery name="new_process">
    <querytext>
        insert into pm_process
        (process_id,
         one_line,
         description,
         party_id,
         creation_date)
        values
        (:process_id,
         :one_line,
         :description,
         :party_id,
         :creation_date)
    </querytext>
  </fullquery>

  <fullquery name="edit_process">
    <querytext>
        update pm_process
        set one_line = :one_line,
        description  = :description,
        party_id     = :party_id
    </querytext>
  </fullquery>

  <fullquery name="process_query">
    <querytext>
        select
        process_id,
        one_line,
        description,
        party_id,
        creation_date
        from
        pm_process
        where process_id = :process_id
    </querytext>
  </fullquery>

</queryset>
