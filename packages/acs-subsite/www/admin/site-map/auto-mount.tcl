# /packages/acs-subsite/www/admin/site-map/auto-mount.tcl

ad_page_contract {

    Automatically mounts a package beneath the specified node

    @author mbryzek@arsdigita.com
    @creation-date Fri Feb  9 20:27:26 2001
    @cvs-id $Id: auto-mount.tcl,v 1.8 2018/02/02 00:05:53 gustafn Exp $

} {
    package_key:token,notnull
    node_id:naturalnum,notnull
    {return_url:localurl ""}
}

subsite::auto_mount_application -node_id $node_id $package_key

if {$return_url eq ""} {
    set return_url [site_node::get_url -node_id]
}

ad_returnredirect $return_url
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
