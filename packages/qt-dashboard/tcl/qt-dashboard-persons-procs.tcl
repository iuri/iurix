# /packages/qt-dashboard/tcl/qt-dashboard-persons-procs.tcl

ad_library {

    Utility functions for Qonteo Dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020

}


namespace eval qt {}
namespace eval qt::dashboard {}
namespace eval qt::dashboard::persons {}


ad_proc qt::dashboard::persons::get {
    {-url}
    {-body}
} {
    It retrieves quantity of persons in the requested period of time

    RESPONSE Example 
    # status 200 time 0:2511 headers d5 body {[{"genero":"Femenino","COUNT(*)":10},{"genero":"Masculino","COUNT(*)":308}]} https {sslversion TLSv1.2 cipher ECDHE-RSA-CHACHA20-POLY1305}

    
} {
    

    
    
    
    ns_log Notice "BODY $body"
    
    #######################
    # submit POST request
    #######################
    set requestHeaders [ns_set create]
    set replyHeaders [ns_set create]
    ns_set update $requestHeaders "Content-type" "application/json"
    
    set h [ns_http queue -method POST \
	       -headers $requestHeaders \
	       -timeout 60.0 \
	       -body $body \
	       $url]
    set result [ns_http wait $h]
    
    #######################
    # output results
    #######################
    # ns_log notice "status [dict get $result status]"
    
    ns_log Notice "RESLUT $result"
    
    ns_log Notice "STATUS [dict get $result status]"

    ns_log Notice "BODY [dict get $result body]"

    return $result
    
}


