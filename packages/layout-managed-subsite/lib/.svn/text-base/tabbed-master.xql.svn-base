<?xml version="1.0"?>

<queryset>

  <fullquery name="select_pageset_pages">
    <querytext>
      select lp.name as label, lp.sort_key as tabindex, url_name as href
      from layout_pages lp
      where lp.pageset_id = :pageset_id
      and exists (select 1
                    from layout_elements le, acs_object_party_privilege_map aoppm
                    where le.page_id = lp.page_id
                      and le.state <> 'hidden'
                      and aoppm.object_id = le.package_id
                      and aoppm.party_id = :user_id
                      and aoppm.privilege = le.required_privilege)
      order by lp.sort_key
    </querytext>
  </fullquery>


  <fullquery name="select_pageset_pages_all">
    <querytext>
      select lp.name as label, lp.sort_key as tabindex, url_name as href
      from layout_pages lp
      where lp.pageset_id = :pageset_id
      order by lp.sort_key
    </querytext>
  </fullquery>

</queryset>
