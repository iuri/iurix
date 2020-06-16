# /packages/ctree-core/tcl/ctree-procs.tcl

ad_library {

    Utility functions for Ctree package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Oct 14th 2019

}

namespace eval ctree {}

namespace eval ctree::tree {}

ad_proc ctree::tree::new {
    {-name}
    {-parent_id ""}
    {-content_type}
    {-attributes}
    {-add_p f}
} {
    Gets entire tree and insets into the datamodel 

} {
    ns_log Notice "Running ad_proc ctree::tree::new"
    #    ns_log Notice "Adding new $content_type \n $name \n $parent_id \n $attributes"
    # ns_log Notice "NAME $name \n"
    #ns_log Notice "ATTRIBS $attributes \n LENGTH [llength $attributes]"
    
    array set arr $attributes
    
    set item_id [db_nextval "acs_object_id_seq"]
    
    # Inserting TREE
    set creation_user [ad_conn user_id]
    set creation_ip [ad_conn peeraddr]
    set package_id [ad_conn package_id]
    set storage_type "text"
    
    if {$parent_id eq "" } {
	set parent_id $package_id
    }
    ns_log Notice "ADDP $add_p"
    
    if {$add_p} {
	if {[info exists arr(name)]} {
	    set pretty_name $arr(name)
	} else {
	    set pretty_name $name
	}
	
	ns_log Notice "NAME $name | pretty name $pretty_name"
	
	set name [util_text_to_url [string map {á a à a â a ã a ç c é e è e ê e í i ó o õ o ô o ú u "´" "" "'" "" " " - "," -} [string tolower $name]]]
	
	if {![db_0or1row item_exists {
	    SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :parent_id
	}]} {	    
	    
	    db_transaction {
		set item_id [content::item::new \
				 -item_id $item_id \
				 -parent_id $parent_id \
				 -creation_user $creation_user \
				 -creation_ip $creation_ip \
				 -package_id $package_id \
				 -name "$name" \
				 -title "$pretty_name" \
				 -description $attributes \
				 -storage_type "$storage_type" \
				 -content_type $content_type \
				 -mime_type "text/plain"
			    ]
	    }	    	    
	    set item_attributes [list]
	    #lappend attributes [list cnpj $cnpj]		
	    #lappend attributes [list url $name]	    
	    set revision_id [content::revision::new \
				 -item_id $item_id \
				 -title $pretty_name \
				 -description $attributes \
				 -attributes $item_attributes]	   	    
	} else {
	    ns_log Notice "TREE EXISTS"
	    db_1row item_exists {
		SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :parent_id
	    }
	}




	
	foreach attrib [array names arr] {
	# ns_log Notice "$attrib [llength $arr($attrib)]"
	    for {set i 0} {$i < [llength $arr($attrib)]} {incr i} {
		# ns_log Notice "***** [lindex \"$arr($attrib)\" $i]"
		set flag true
		switch $attrib {
		    "descriptions" {
			set content_type "ctree_description"
			set n [lindex [lindex "$arr($attrib)" [expr $i + 1]] [expr 1 +1]]
			ns_log Notice "NAME $n"
			#ctree::tree::new -name $n -content_type $content_type -attributes [lindex "$arr($attrib)" [expr $i + 1]] -parent_id $item_id -add_p $flag
			
		    }	    
		    "types" {
			set content_type "ctree_type"
		    }	    
		    "segmentTypes" {	
			set content_type "ctree_segmenttype"		
		    }
		    "feedback" {
			set content_type "ctree_feedback"		
		    }	    
		    "elements" {	
			set content_type "ctree_post"		
		    }	    
		    "segmentVariations" {	
			set content_type "ctree_segmentvariation"		
		    }
		    default {
			set flag false
		    }
		}
		if {$flag} {
		    ns_log Notice "FLAG $flag *******"
		    ns_log Notice "ADD ITEM \n
			-name [lindex \"$arr($attrib)\" $i] \n
			-content_type $content_type \n
			-attributes [lindex \"$arr($attrib)\" [expr $i + 1]] \n
			-parent_id $item_id \n
			-add_p $flag
		    "
		    
		    ctree::tree::new -name [lindex "$arr($attrib)" $i] -content_type $content_type -attributes [lindex "$arr($attrib)" [expr $i + 1]] -parent_id $item_id -add_p $flag
		    incr i
		}
	    }	
	} 	
    }
}    



    









ad_proc ctree::get_tree {
    {str}
} {
    given a string it returns cTree data
    https://github.com/F4IF/ctree-demo/blob/mvp/firebase-export.json
} {


    return 1
}



ad_proc ctree::new {
    
} {
    IT adds a new ctree into the datamodel
    
} {


    set creation_user [ad_conn user_id]
    set creation_ip [ad_conn peeraddr]
    set package_id [ad_conn package_id]
    set storage_type "text"
    set parent_id $package_id
    
    db_transaction {
	if {![db_string item_exists {}]} {
	    set item_id [content::item::new \
			     -item_id $item_id \
			     -parent_id $parent_id \
			     -creation_user $creation_user \
			     -creation_ip "$creation_ip" \
			     -package_id "$package_id" \
			     -name "$name" \
			     -storage_type "$storage_type" \
			     -content_type "ctree" \
			     -mime_type "text/plain"
			]
	    if {$creation_user ne ""} {
		permission::grant -party_id $creation_user -object_id $item_id -privilege admin
	    }
	}


	set attributes [list]
	lappend attributes [list cnpj $cnpj]
	lappend attributes [list url $name]

	set revision_id [content::revision::new \
			     -item_id $item_id \
			     -title $business_name \
			     -description $descricao \
			     -attributes $attributes]
    }

    
}
