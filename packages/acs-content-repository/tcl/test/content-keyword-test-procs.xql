<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">
<!--  -->
<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2005-03-20 -->
<!-- @cvs-id $Id: content-keyword-test-procs.xql,v 1.2 2018/08/15 17:00:24 gustafn Exp $ -->

<queryset>
  <fullquery name="_acs-content-repository__content_keyword.confirm_delete">
    <querytext>
      select keyword_id from cr_keywords where keyword_id=:keyword_id
    </querytext>
  </fullquery>
</queryset>
