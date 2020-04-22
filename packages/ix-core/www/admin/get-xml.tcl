ad_page_contract {

    Reference: https://xml.movida.com.br/movida/ws3/manual/index.php
}

set auth_url "http://ws3.dev.movidacloud.com.br/movida/ws3/index.php"


set headers [ns_set create headers]

# Normalize url. Slashes at the end can make
# the same url don't look the same for the
# server, if we retrieve the same url from
# the 'action' attribute of the form.
set auth_url [string trimright $auth_url "/"]
set base_url [split $auth_url "/"]
set base_url [lindex $base_url 0]//[lindex $base_url 2]

# Call login url to obtain login form
array set r [util::http::get -url "https://iurix.com/request-sample.xml"]

# Call login url with authentication parameters. Just retrieve the first response, as it
# is common for login pages to redirect somewhere, but we just need to steal the cookies.
array set r [util::http::post \
		 -url $auth_url \
		 -headers $headers -max_depth 0 \
		 -body $r(page)]



ns_log Notice "[parray r]"


ad_return_template get-xml
