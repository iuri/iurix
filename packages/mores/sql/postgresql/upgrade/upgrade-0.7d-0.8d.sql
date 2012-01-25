-- /packages/mores/sql/postgresql/upgrade/upgrade-0.7d-0.8d.sql

SELECT acs_log__debug('/packages/mores/sql/postgresql/upgrade/upgrade-0.7d-0.8d.sql','');

DROP TABLE mores_items_tmp;

CREATE TABLE mores_items_tmp
(
  user_id character varying,
  user_nick character varying,
  user_name character varying,
  profile_img character varying,
  post_id character varying NOT NULL,
  created_at timestamp with time zone NOT NULL,
  title character varying,
  "text" character varying NOT NULL,
  lang character varying,
  post_url character varying NOT NULL,
  "type" character varying,
  followers integer,
  following integer,
  favorites integer,
  statuses integer,
  verified integer,
  CONSTRAINT mores_items_tmp_post_id_key PRIMARY KEY (post_id)
) WITH (
  OIDS=TRUE
);