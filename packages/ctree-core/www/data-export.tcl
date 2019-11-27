

doc_return 200 "application/json" {
    "ctrees" : {
	"<default>" : {
	    "segmentTypes" : {
		"9df0e7c6-89f9-ccd0-84ff-7d26dd589c8a" : {
		    "canBeThumbnail" : false,
		    "componentName" : "ctree-segment-text"
		},
		"501f7439-ac3e-9562-2bf4-3a32b89ca6cf" : {
		    "canBeThumbnail" : true,
		    "componentName" : "ctree-segment-image"
		}
	    },
	    "types" : {
		"21ec137f-d241-1062-535d-348db8190275" : {
		    "color" : "#8a5b15",
		    "description" : "What this cTree is about",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Subject",
		    "parentsMax" : 0,
		    "parentsRequired" : false,
		    "prompt" : "Create cTree"
		},
		"725d347c-7990-8cc7-f63f-7fb92009b853" : {
		    "color" : "#d58c20",
		    "description" : "Areas which need to be addresed",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Goals",
		    "parentTypes" : [ null, "21ec137f-d241-1062-535d-348db8190275", "725d347c-7990-8cc7-f63f-7fb92009b853" ],
		    "parentsMax" : -1,
		    "parentsRequired" : true,
		    "prompt" : "Add goal"
		},
		"e19ce806-319b-cec9-dba2-16d7dcebd700" : {
		    "color" : "#16ad16",
		    "description" : "How to structure or accomplish suggestion",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Implementation",
		    "parentTypes" : [ null, "e19ce806-319b-cec9-dba2-16d7dcebd700", "77ffc744-2142-c4cc-8366-35d4c3a6f23b", "8e4d0986-7fc1-fdde-a167-bcb905702193" ],
		    "parentsMax" : 1,
		    "parentsRequired" : true,
		    "prompt" : "Suggest implementation"
		},
		"890a8cf3-4a9d-3a59-212f-63c903b918fa" : {
		    "color" : "#d1d100",
		    "description" : "Something which needs to be answered",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Question",
		    "parentTypes" : [ null, "725d347c-7990-8cc7-f63f-7fb92009b853", "e19ce806-319b-cec9-dba2-16d7dcebd700", "77ffc744-2142-c4cc-8366-35d4c3a6f23b", "8e4d0986-7fc1-fdde-a167-bcb905702193" ],
		    "parentsMax" : 1,
		    "parentsRequired" : true,
		    "prompt" : "Ask question"
		},
		"77ffc744-2142-c4cc-8366-35d4c3a6f23b" : {
		    "color" : "#2c2ce2",
		    "description" : "Possible answer to question",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Answer",
		    "parentTypes" : [ null, "890a8cf3-4a9d-3a59-212f-63c903b918fa" ],
		    "parentsMax" : -1,
		    "parentsRequired" : true,
		    "prompt" : "Answer question"
		},
		"5a7c59ba-add8-e251-9eb2-5801058c9e80" : {
		    "color" : "#e12323",
		    "description" : "Issue which needs to be solved",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Problem",
		    "parentTypes" : [ null, "725d347c-7990-8cc7-f63f-7fb92009b853", "e19ce806-319b-cec9-dba2-16d7dcebd700", "77ffc744-2142-c4cc-8366-35d4c3a6f23b", "8e4d0986-7fc1-fdde-a167-bcb905702193" ],
		    "parentsMax" : 1,
		    "parentsRequired" : true,
		    "prompt" : "Identify problem"
		},
		"8e4d0986-7fc1-fdde-a167-bcb905702193" : {
		    "color" : "#00aeae",
		    "description" : "Potential way to address problem",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Solution",
		    "parentTypes" : [ null, "5a7c59ba-add8-e251-9eb2-5801058c9e80" ],
		    "parentsMax" : -1,
		    "parentsRequired" : true,
		    "prompt" : "Suggest solution"
		}
	    }
	},
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
	    "name" : "Test",
	    "segmentTypes" : {
		"9df0e7c6-89f9-ccd0-84ff-7d26dd589c8a" : {
		    "canBeThumbnail" : false,
		    "componentName" : "ctree-segment-text"
		},
		"501f7439-ac3e-9562-2bf4-3a32b89ca6cf" : {
		    "canBeThumbnail" : true,
		    "componentName" : "ctree-segment-image"
		}
	    },
	    "segmentVariations" : {
		"forSegment" : {
		    "f07cd2c4-46d3-7516-ec91-f618ef539437" : {
			"42e4fc57-d485-6faf-d2ed-e5b4a4f65343" : {
			    "data" : "test description 1",
			    "rating" : 0,
			    "type" : "9df0e7c6-89f9-ccd0-84ff-7d26dd589c8a"
			}
		    },
		    "6a2f5405-4004-973b-0b83-2b4807b22016" : {
			"bc8dbc57-a087-99a4-9faa-51efd858e377" : {
			    "data" : "test description 2",
			    "rating" : 0,
			    "type" : "9df0e7c6-89f9-ccd0-84ff-7d26dd589c8a"
			}
		    }
		}
	    },
	    "types" : {
		"21ec137f-d241-1062-535d-348db8190275" : {
		    "color" : "#8a5b15",
		    "description" : "What this cTree is about",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Subject",
		    "parentsMax" : 0,
		    "parentsRequired" : false,
		    "prompt" : "Create cTree"
		},
		"725d347c-7990-8cc7-f63f-7fb92009b853" : {
		    "color" : "#d58c20",
		    "description" : "Areas which need to be addresed",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Goals",
		    "parentTypes" : [ null, "21ec137f-d241-1062-535d-348db8190275", "725d347c-7990-8cc7-f63f-7fb92009b853" ],
		    "parentsMax" : -1,
		    "parentsRequired" : true,
		    "prompt" : "Add goal"
		},
		"e19ce806-319b-cec9-dba2-16d7dcebd700" : {
		    "color" : "#16ad16",
		    "description" : "How to structure or accomplish suggestion",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Implementation",
		    "parentTypes" : [ null, "e19ce806-319b-cec9-dba2-16d7dcebd700", "77ffc744-2142-c4cc-8366-35d4c3a6f23b", "8e4d0986-7fc1-fdde-a167-bcb905702193" ],
		    "parentsMax" : 1,
		    "parentsRequired" : true,
		    "prompt" : "Suggest implementation"
		},
		"890a8cf3-4a9d-3a59-212f-63c903b918fa" : {
		    "color" : "#d1d100",
		    "description" : "Something which needs to be answered",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Question",
		    "parentTypes" : [ null, "725d347c-7990-8cc7-f63f-7fb92009b853", "e19ce806-319b-cec9-dba2-16d7dcebd700", "77ffc744-2142-c4cc-8366-35d4c3a6f23b", "8e4d0986-7fc1-fdde-a167-bcb905702193" ],
		    "parentsMax" : 1,
		    "parentsRequired" : true,
		    "prompt" : "Ask question"
		},
		"77ffc744-2142-c4cc-8366-35d4c3a6f23b" : {
		    "color" : "#2c2ce2",
		    "description" : "Possible answer to question",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Answer",
		    "parentTypes" : [ null, "890a8cf3-4a9d-3a59-212f-63c903b918fa" ],
		    "parentsMax" : -1,
		    "parentsRequired" : true,
		    "prompt" : "Answer question"
		},
		"5a7c59ba-add8-e251-9eb2-5801058c9e80" : {
		    "color" : "#e12323",
		    "description" : "Issue which needs to be solved",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Problem",
		    "parentTypes" : [ null, "725d347c-7990-8cc7-f63f-7fb92009b853", "e19ce806-319b-cec9-dba2-16d7dcebd700", "77ffc744-2142-c4cc-8366-35d4c3a6f23b", "8e4d0986-7fc1-fdde-a167-bcb905702193" ],
		    "parentsMax" : 1,
		    "parentsRequired" : true,
		    "prompt" : "Identify problem"
		},
		"8e4d0986-7fc1-fdde-a167-bcb905702193" : {
		    "color" : "#00aeae",
		    "description" : "Potential way to address problem",
		    "iconUrl" : "/images/app-icon-32.png",
		    "name" : "Solution",
		    "parentTypes" : [ null, "5a7c59ba-add8-e251-9eb2-5801058c9e80" ],
		    "parentsMax" : -1,
		    "parentsRequired" : true,
		    "prompt" : "Suggest solution"
		}
	    }
	}
    }
}
