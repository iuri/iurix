<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">

<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2004-05-09 -->
<!-- @cvs-id $Id: copy-postgresql.xql,v 1.9.2.2 2019/08/28 14:31:41 antoniop Exp $ -->

<queryset>
  
  <rdbms>
    <type>postgresql</type>
    <version>7.2</version>
  </rdbms>

  <fullquery name="copy_item">
    <querytext>
      select file_storage__copy_file(
           :object_id,
           :folder_id,
	   :user_id,
           :peer_addr,
	   :name,
	   :title
      )
    </querytext>
  </fullquery>

  <fullquery name="copy_folder">
    <querytext>
      select content_folder__copy (
           :object_id,
           :folder_id,
	   :user_id,
           :peer_addr,
	   :name,
	   :title
      )
    </querytext>
  </fullquery>

</queryset>
