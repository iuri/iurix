ad_page_contract {     
    Generates a tarball for a package into its distribution_tarball field.    
    
    @param version_id The package version to be processed.
    @author Bryan Quinn (bquinn@arsdigita.com)
    @creation-date 9 May 2000
    @cvs-id $Id: version-generate-tarball.tcl,v 1.7 2018/01/19 13:40:40 gustafn Exp $
} {
    {version_id:naturalnum,notnull}
}
db_transaction {
    apm_generate_tarball $version_id
} on_error {
    ad_return_complaint 1 "APM Generation Error: The database returned the following error message:
<pre>
<blockquote>
[ns_quotehtml $errmsg]
</blockquote>
</pre>
"
}

ad_returnredirect "version-view?version_id=$version_id"
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
