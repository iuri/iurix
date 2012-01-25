<?xml version="1.0"?>

<queryset>

  <fullquery name="get_services">
    <querytext>
      select apt.package_key
      from apm_package_types apt
      where exists (select 1
                    from layout_includelets li
                    where apt.package_key = li.application)
        and apt.package_type = 'apm_service'
      order by apt.package_key
    </querytext>
  </fullquery>

  <fullquery name="get_service_includelets">
    <querytext>
      select li.title, count(*)
      from layout_includelets li, layout_elements le, layout_pages lp
      where lp.pageset_id = :pageset_id
        and le.page_id = lp.page_id
        and le.includelet_name = li.name
        and li.application = :package_key
      group by li.title
      order by li.title
    </querytext>
  </fullquery>

  <fullquery name="get_mounted_includelets">
    <querytext>
      select li.title, count(*)
      from layout_includelets li, layout_elements le, layout_pages lp
      where lp.pageset_id = :pageset_id
        and le.package_id = :package_id
        and le.page_id = lp.page_id
        and le.includelet_name = li.name
      group by li.title
      order by li.title
    </querytext>
  </fullquery>

</queryset>
