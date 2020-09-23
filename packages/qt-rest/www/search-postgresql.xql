<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>9.6</version></rdbms>
<fullquery name="select_top_plate1">
  <querytext>
        SELECT cr.title,
    MAX(o.creation_date) AS creation_date,
    COUNT(*) AS occurency
    FROM cr_items ci,
    cr_revisionsx cr,
    acs_objects o
    WHERE ci.item_id = cr.item_id
    AND ci.item_id = o.object_id
    AND ci.content_type = 'qt_vehicle'
--    AND cr.title !~ '^[0-9]'
    AND cr.title NOT IN ('UNKNOWN', 'FBF724','FBF124')
    GROUP BY cr.title
    HAVING COUNT(*) > 1
    ORDER BY COUNT(*) DESC
    LIMIT 1

  </querytext>
</fullquery>

<fullquery name="select_top_plate_month1">
  <querytext>
SELECT cr.title,
    MAX(o.creation_date) AS creation_date,
    COUNT(*) AS occurency
    FROM cr_items ci,
    cr_revisionsx cr,
    acs_objects o
    WHERE ci.item_id = cr.item_id
    AND ci.item_id = o.object_id
    AND ci.content_type = 'qt_vehicle'
  --  AND cr.title !~ '^[0-9]'
    AND cr.title NOT IN ('UNKNOWN', 'FBF724','FBF124')
    $where_clauses
    GROUP BY cr.title
    HAVING COUNT(*) > 1
    ORDER BY COUNT(*) DESC
    LIMIT 1
  </querytext>
</fullquery>

<fullquery name="select_vehicles1">

  <querytext>
        SELECT cr.title,
        MAX(o.creation_date) AS creation_date,       
        COUNT(*) AS occurency
        FROM cr_items ci,
        cr_revisionsx cr,
        acs_objects o
        WHERE ci.item_id = cr.item_id
        AND ci.item_id = o.object_id 
        AND ci.content_type = 'qt_vehicle'
--	AND cr.title !~ '^[0-9]'
	AND cr.title NOT IN ('UNKNOWN', 'FBF724', 'FBF124')
        $where_clauses 
        GROUP BY cr.title
        HAVING COUNT(*) > 1
        ORDER BY MAX(cr.creation_date) DESC 
        LIMIT $limit OFFSET $offset;        

  </querytext>
</fullquery>

<fullquery name="count_records1">
  <querytext>
            SELECT SUM(total) AS total FROM (
        SELECT DISTINCT(cr.title),
        COUNT(ci.live_revision) AS total
        FROM cr_items ci,
        cr_revisionsx cr,
        acs_objects o
        WHERE ci.item_id = cr.item_id
        AND ci.item_id = o.object_id
        AND ci.live_revision = cr.revision_id
        AND ci.content_type = 'qt_vehicle'
--	AND cr.title !~ '^[0-9]'
        AND cr.title NOT IN ( 'UNKNOWN', 'FBF724', 'FBF124')
        $where_clauses 
        GROUP BY cr.title
        HAVING COUNT(ci.live_revision) > 1 ) t
  </querytext>
</fullquery>

</queryset>
