
package require websocket
::websocket::loglevel debug
proc handler { sock type msg } {
    switch -glob -nocase -- $type {
	co* {
	    ns_log Notice "Connected on $sock"
	    puts "Connected on $sock"
	    
	}
	te* {
	    ns_log Notice "RECEIVED $msg"
	    puts "RECEIVED: $msg"
	}
	cl* -
	dis* {
	}
    }

}
proc test { sock } {
    puts "[::websocket::conninfo $sock type] from [::websocket::conninfo $sock sockname] to [::websocket::conninfo $sock peername]"

    ::websocket::send $sock text "Testing, testing..."
}
set sock [::websocket::open wss://javascript.info/article/websocket/demo/hello handler]
ns_log Notice "SOCKET \n $socket"
after 400 test $sock
vwait forever


