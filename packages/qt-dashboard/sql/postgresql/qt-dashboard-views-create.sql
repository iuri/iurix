--
-- qt-dashboard/sql/postgresql/qt-dashboard-views-create.sql
--
-- @author Iuri Sampaio (iuri@iurix.com)
-- @creation-date 2020-10-16



CREATE VIEW qt_select_types_count AS
       SELECT v.creation_date::date AS date,
       split_part(v.description, ' ', 25) AS type,
       COUNT(1) AS count
       FROM qt_vehicle_ti v
       GROUP BY date, type, 1
       ORDER BY date;




CREATE VIEW qt_select_past_totals_per_hour AS
    SELECT date_trunc('hour', creation_date) AS hour,
    COUNT(1) AS total
    FROM qt_vehicle_ti
    WHERE creation_date::date < now()::date - INTERVAL '1 day'
    GROUP BY 1
    ORDER BY hour;
