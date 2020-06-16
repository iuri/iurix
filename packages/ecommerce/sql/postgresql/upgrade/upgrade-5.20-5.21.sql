---- /packages/ecommerce/sql/postgresql/upgrade/upgrade-5.20-5.21.sql
---- Iuri de Araujo (iuri@iurix.com)
---- creation_date 2020-02-14
---- Added suport to categorization hierarchy

ALTER TABLE ec_categories ADD COLUMN parent_id integer;
ALTER TABLE ec_categories ADD CONSTRAINT ec_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES ec_categories (category_id) MATCH FULL;
						 
