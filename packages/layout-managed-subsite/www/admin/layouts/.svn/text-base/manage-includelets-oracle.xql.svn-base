<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="get_elements">
    <querytext>
      select le.*
      from layout_elements le, layout_pages lp, layout_includelets li
      where le.package_id = :package_id
        and lp.page_id = le.page_id
        and lp.pageset_id = :pageset_id
        and le.includelet_name = li.name
        and apm_package.is_child(li.application, :package_key) = 1
      order by le.title
    </querytext>
  </fullquery>

  <fullquery name="get_includelets">
    <querytext>
      select li.*
      from layout_includelets li
      where apm_package.is_child(li.application, :package_key) = 1
        and li.internally_managed_p = 'f'
        and not exists (select 1
                        from layout_elements le
                        where le.package_id = :package_id
                          and le.includelet_name = li.name
                          and li.singleton_p = 't')
      order by li.name
    </querytext>
  </fullquery>
</queryset>
