ns_log Notice "Running TCL script luna.tcl"


set url "ws://192.199.241.130:5008/api/subscribe?auth_token=9fb6e731-b342-4952-b0c1-aa1d0b52757b&event_type=extract"
#set url "wss://javascript.info/article/websocket/demo/hello"
ws::client::close conn0

set channel [ws::client::open $url]
ns_log Notice "NEW CHANNEL $channel"

set i 0
while {$i < 1} {
    set result [ws::client::receive $channel]
    ns_log Notice "RESULT \n $result"
#    {{"result":{"faces":[{"attributes":{"age":40.4277687073,"eyeglasses":0,"gender":1},"id":"71f91150-e8dc-41d1-b94e-52f037b83624","rect":{"height":164,"width":129,"x":55,"y":60},"score":0.9653117061,"rectISO":{"height":315,"width":236,"x":9,"y":-24}}]},"timestamp":1594603141.1834712029,"source":"descriptors","event_type":"extract","authorization":"basic"}} {} 1

   # {{"result":{"faces":[{"attributes":{"age":54.7560386658,"eyeglasses":0,"gender":1},"id":"77e6af49-c9c3-4063-a1f5-022be46a2b42","rect":{"height":171,"width":126,"x":57,"y":51},"score":0.9543465376,"rectISO":{"height":315,"width":236,"x":9,"y":-25}}]},"timestamp":1594682300.5146231651,"source":"descriptors","event_type":"extract","authorization":"basic"}} {} 1

    # {{"result":{"faces":[{"attributes":{"age":40.1215324402,"eyeglasses":0,"gender":0},"id":"5b54bb2b-6b35-49c8-b168-12c0405269f9","rect":{"height":152,"width":131,"x":59,"y":55},"score":0.9570939541,"rectISO":{"height":320,"width":240,"x":8,"y":-29}}]},"timestamp":1594682437.9599757195,"source":"descriptors","event_type":"extract","authorization":"basic"}} {} 1

    

}

ws::client::close $channel

# vwaitforever

#
# Local variables:
#    mode: tcl