ad_page_contract {}

set total "00:00"
db_multirow asd select_asd {
    WITH
    cte1 AS (SELECT v1.title, SPLIT_PART(v1.description, ' ', 25) AS type, MIN(v1.creation_date::timestamp) AS min_entry FROM qt_vehicle_ti v1 WHERE v1.creation_date::date = '2020-10-06' AND SPLIT_PART(v1.description, ' ', 21) = 'Cam14' AND title != 'UNKNOWN' GROUP BY v1.title, type ORDER BY min_entry ASC ),
    cte2 AS (SELECT v2.title, SPLIT_PART(v2.description, ' ', 25) AS type, MAX(v2.creation_date::timestamp) AS max_exit FROM qt_vehicle_ti v2 WHERE v2.creation_date::date = '2020-10-06' AND SPLIT_PART(v2.description, ' ', 21) = 'Cam11' AND title != 'UNKNOWN' GROUP BY v2.title, type ORDER BY max_exit ASC)
    --    SELECT cte1.title, cte1.min_entry, cte2.max_exit FROM cte1, cte2 WHERE cte1.title = cte2.title AND cte2.max_exit BETWEEN cte1.min_entry AND cte1.min_entry + INTERVAL '30 minutes' ORDER BY cte1.min_entry ASC;

        SELECT cte2.type, AVG(cte2.max_exit - cte1.min_entry) AS avg FROM cte1, cte2 WHERE cte1.title = cte2.title AND cte2.max_exit BETWEEN cte1.min_entry AND cte1.min_entry + INTERVAL '30 minutes' GROUP BY cte2.type;
} {


    ns_log Notice "AVG $avg"
}
ns_log Notice "TOTAL [set asd:rowcount]"
