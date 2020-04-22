ad_page_contract {}

set json "
    \"ctrees" : {
	"test" : {
	    "descriptions" : {
		"forElement" : {
		    "2433fa24-3570-3e30-e032-03b81dd8ddcb" : {
			"246113fd-067a-f126-f406-3fea6605049f" : {
			    "rating" : 0,
			    "segments" : [ "f07cd2c4-46d3-7516-ec91-f618ef539437" ]
			}
		    },
		    "bcd09662-a73f-93ce-56e5-930a6af3ef1a" : {
			"b7aa416a-b185-2c05-709c-710b140440b0" : {
			    "rating" : 0,
			    "segments" : [ "6a2f5405-4004-973b-0b83-2b4807b22016" ]
			}
		    }
		}
	    },
	    "elements" : {
		"2433fa24-3570-3e30-e032-03b81dd8ddcb" : {
		    "childCount" : 1,
		    "createdDate" : 123456789,
		    "feedbackCount" : 1,
		    "interactionCount" : 0,
		    "lastInteractionDate" : 12345789,
		    "rating" : 0,
		    "title" : "test1",
		    "type" : "21ec137f-d241-1062-535d-348db8190275"
		},
		"bcd09662-a73f-93ce-56e5-930a6af3ef1a" : {
		    "childCount" : 0,
		    "createdDate" : 12345679,
		    "feedbackCount" : 0,
		    "interactionCount" : 0,
		    "lastInteractionDate" : 12345689,
		    "parents" : {
			"2433fa24-3570-3e30-e032-03b81dd8ddcb" : {
			    "rating" : 1
			}
		    },
		    "rating" : 1,
		    "title" : "test2",
		    "type" : "725d347c-7990-8cc7-f63f-7fb92009b853"
		}
	    },
	    "feedback" : {
		"forDescription" : {
		    "246113fd-067a-f126-f406-3fea6605049f" : {
			"18986a2d-7a73-8c4f-b4f1-110fe91bc45f" : {
			    "rating" : 0,
			    "text" : "test comment"
			}
		    }
		}
	    },
	    "name" : "Test"
	    
	    
	}
    }
"
