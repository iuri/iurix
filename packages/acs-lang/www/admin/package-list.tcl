ad_page_contract {
    Displays packages that contain messages.

    @author Bruno Mattarollo <bruno.mattarollo@ams.greenpeace.org>
    @author Lars Pind (lars@collaboraid.biz)

    @creation-date 26 October 2001
    @cvs-id $Id: package-list.tcl,v 1.14.2.2 2019/12/20 21:47:58 gustafn Exp $
} {
    locale:word
} -properties {
    current_locale_label
    page_title
    context
    current_locale
    default_locale
    packages:multirow
    search_form
}

# SWA?
set site_wide_admin_p [acs_user::site_wide_admin_p]

# We rename to avoid conflict in queries
set current_locale $locale
set current_locale_label [lang::util::get_label $current_locale]
set default_locale en_US
set default_locale_label [lang::util::get_label $default_locale]
set default_locale_p [string equal $current_locale $default_locale]
set locale_enabled_p [expr {[lsearch [lang::system::get_locales] $current_locale] != -1}]

# URLs
set import_all_url [export_vars -base import-messages { { locale $current_locale } {return_url {[ad_return_url]}} }]
set export_all_url [export_vars -base export-messages { { locale $current_locale } {return_url {[ad_return_url]}} }]

# Page title and context
set page_title $current_locale_label
set context [list $page_title]

# Package/message list
if { $default_locale_p } {
    set multirow packages_locale_status_default
} else {
    set multirow packages_locale_status
}

# Package/message list
db_multirow -extend {
    num_messages_pretty
    num_translated_pretty
    num_untranslated_pretty
    num_deleted_pretty
    batch_edit_url
    view_messages_url
    view_translated_url
    view_deleted_url
    view_untranslated_url
} packages $multirow {} {
    set num_messages_pretty     [lc_numeric $num_messages]
    set num_translated_pretty   [lc_numeric $num_translated]
    set num_untranslated_pretty [lc_numeric $num_untranslated]
    set num_deleted_pretty      [lc_numeric $num_deleted]

    set batch_edit_url          [export_vars -base batch-editor { locale package_key }]
    set view_messages_url       [export_vars -base message-list { locale package_key }]
    set view_translated_url     [export_vars -base message-list { locale package_key { show "translated" } }]
    set view_deleted_url        [export_vars -base message-list { locale package_key { show "deleted" } }]
    set view_untranslated_url   [export_vars -base message-list { locale package_key { show "untranslated" } }]
}

# Search form
set search_locales [list \
                        [list "Current locale - [lang::util::get_label $current_locale]" $current_locale] \
                        [list "Master locale - [lang::util::get_label $default_locale]" $default_locale]]

ad_form -has_submit 1 -name search -action message-search -form {
    {locale:text(hidden) {value $locale}}
}

if { $default_locale ne $current_locale } {
    ad_form -extend -name search -form {
        {search_locale:text(select)
            {options $search_locales}
            {label "Search locale"}
        }
    }
} else {
    ad_form -extend -name search -form {
        {search_locale:text(hidden)
            {value $current_locale}
        }
    }
}

ad_form -extend -name search -form {
    {q:text
        {label "Search for"}
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
