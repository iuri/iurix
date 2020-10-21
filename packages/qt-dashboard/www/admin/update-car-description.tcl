

# -- id 323659 plate_number IWR425 country_name Colombia country_symbol CO first_seen {2020-09-06 12:46:57} last_seen {2020-09-06 12:46:58} probability 1 location_name Test camera_name {LPR 3} direction COMING car_class Car plate_image http://178.62.211.78/plate_image_fa.php?id=323659 car_image http://178.62.211.78/car_image_fa.php?id=323659

# -- id 138232 plate_number UNKNOWN country_name Unknown country_symbol ?? first_seen {2020-08-01 17:58:53} last_seen {2020-08-01 17:58:53} probability 0.2 location_name Test camera_name {LPR 3} direction UNKNOWN car_class UNKNOWN plate_image http://178.62.211.78/plate_image_fa.php?id=138232 car_image http://178.62.211.78/car_image_fa.php?id=138232

# -- id 138232 plate_number UNKNOWN country_name Unknown country_symbol ?? first_seen {2020-08-01 17:58:53} last_seen {2020-08-01 17:58:53} probability 0.2 location_name Test camera_name LPR3 direction UNKNOWN class UNKNOWN plate_image http://178.62.211.78/plate_image_fa.php?id=138232 car_image http://178.62.211.78/car_image_fa.php?id=138232
# -- id 323666 plate_number WPP533 country_name Colombia country_symbol CO first_seen {2020-09-06 12:48:36} last_seen {2020-09-06 12:48:36} probability 0.4 location_name Test camera_name {LPR 3} direction COMING car_class Car plate_image http://178.62.211.78/plate_image_fa.php?id=323666 car_image http://178.62.211.78/car_image_fa.php?id=323666



#    -- 20200926
#    -- SELECT cr.revision_id, cr.description FROM cr_items ci, acs_objects o, cr_revisions cr WHERE ci.item_id = o.object_id AND ci.item_id = cr.item_id AND ci.latest_revision = cr.revision_id AND ci.content_type = 'qt_vehicle' AND split_part(cr.description, ' ', 24) = 'car_class' AND split_part(cr.description, ' ', 25) = 'UNKNOWN';
#    --    
#    -- 20201009
# SELECT split_part(v.description, ' ', 19) AS type, COUNT(1) AS count FROM qt_vehicle_ti v  GROUP BY type, 1;
# 816903

set i 0


db_foreach select_vehicles "
    SELECT v.object_id AS revision_id, v.description FROM qt_vehicle_ti v  WHERE split_part(v.description, ' ', 19) != 'station\}'  


" {
    ns_log Notice "DESCRIPTION $description"
    # set description [string map {"class" "car_class" "LPR3" "{LPR 3}"} $description]
    # set description [string map {"class UNKNOWN" "car_class Unknown"} $description]

    set description [string map {"{LPR 1}" "LPR1" "Test" "{Gas station}" } $description]
    ns_log Notice "DESCRIPTION $description"    
    
    db_transaction {
	ns_log Notice "    update revision: $revision_id"

	db_dml update_revision {
	    UPDATE cr_revisions SET description = :description WHERE revision_id = :revision_id
	}
    }
    incr i
}



ns_log Notice "FINISHED UPDATING $i  REVISIONS!"
