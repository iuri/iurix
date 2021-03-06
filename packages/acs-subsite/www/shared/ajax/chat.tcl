ad_page_contract {
  A tiny chat client

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at)
  @creation-date Jan 31, 2006
  @cvs-id $Id: chat.tcl,v 1.1.2.4 2020/10/28 15:39:19 hectorr Exp $

} -query {
  m:word
  id:integer
  s
  msg:optional,allhtml
  class:token
  {mode ""}
}

if {[namespace which ::xo::ChatClass] eq "" ||
    ![::xo::ChatClass is_chat_p $class]} {
  ns_returnnotfound

} else {

  #ns_log notice "### chat.tcl mode <$mode> class <$class>"
  #ns_log notice "--chat m=$m session_id=$s [clock format [lindex [split $s .] 1] -format %H:%M:%S] mode=$mode"
  $class create c1 -destroy_on_cleanup -chat_id $id -session_id $s -mode $mode
  switch -- $m {
    add_msg {
      #ns_log notice "--c call c1 $m '$msg'"
      ns_return 200 application/json [c1 $m $msg]
    }
    get_new {
      ns_return 200 application/json [c1 $m]
    }
    subscribe {
      #
      # This method might take the current connection for the
      # subscription. If this is the case, the connection is after
      # this call already closed. Otherwise return a short acknowledge
      # (or error message) for termination.
      #
      set _ [c1 $m]
      if {[ns_conn isconnected]} {
        ns_return 200 text/html [subst {<HTML><body>$_</body></HTML>}]
      }
    }
    login -
    get_all {
      set _ [c1 $m]
      ns_return 200 text/html [subst {<HTML><body>$_</body></HTML>}]
    }
    default {
      ns_log error "--c unknown method $m called."
    }
  }
}

ad_script_abort

#ns_log notice "--chat.tcl $m: returns '$_'"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 2
#    indent-tabs-mode: nil
# End:
