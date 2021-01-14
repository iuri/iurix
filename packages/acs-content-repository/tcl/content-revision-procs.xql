<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">
<!--  -->
<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2005-02-09 -->
<!-- @cvs-id $Id: content-revision-procs.xql,v 1.4.2.1 2020/09/01 17:35:38 antoniop Exp $ -->

<queryset>

  <fullquery name="content::revision::new.get_storage_type">
    <querytext>
      select storage_type from cr_items where item_id=:item_id
    </querytext>
  </fullquery>

</queryset>
