# 

ad_library {
    
    Init file to schedul registered procedures for notifications
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-14
    @arch-tag: e72c34cc-2ed9-42c5-8423-d9b349f0e6c4
    @cvs-id $Id: notification-init.tcl,v 1.3 2005/05/26 09:34:29 maltes Exp $
}

# set up daily emailings
pm::task::email_status_init
