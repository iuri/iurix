-- /packages/mores/sql/postgresql/upgrade/upgrade-0.8d-0.9d.sql

SELECT acs_log__debug('/packages/mores/sql/postgresql/upgrade/upgrade-0.8d-0.9d.sql','');

ALTER TABLE mores_items3 DROP COLUMN favorities;
ALTER TABLE mores_items3 DROP COLUMN favorites;
-- ALTER TABLE mores_items3 ADD COLUMN favorites integer;