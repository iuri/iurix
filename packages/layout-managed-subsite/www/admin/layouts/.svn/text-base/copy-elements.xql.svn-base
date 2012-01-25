<?xml version="1.0"?>

<queryset>

  <fullquery name="get_sort_key">
    <querytext>
      select max(layout_elements.sort_key) + 1
      from layout_elements
      where page_id = :page_id
        and page_column = :page_column
    </querytext>
  </fullquery>

</queryset>
