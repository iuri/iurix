--
-- /packages/ns-core/sql/postgresql/ns-core-create.sql
-- CREATE datamodel
--

-- DROP TABLE ns_mail_criteria;
CREATE TABLE ns_mail_criteria(
       id				integer
					CONSTRAINT ns_mail_criteria_pk
					PRIMARY KEY,
       mail_id				integer
       					CONSTRAINT ns_mail_criteria_fk
       					REFERENCES iurix_mails ON DELETE CASCADE,
       criteria				varchar(50)
);


-- DROP SEQUENCE ns_mail_criteria_seq;
CREATE SEQUENCE ns_mail_criteria_seq;





-- DROP TABLE ns_user_score;
CREATE TABLE ns_user_score(
       id				integer
					CONSTRAINT ns_user_score_pk
					PRIMARY KEY,
       user_id				integer
       					CONSTRAINT ns_user_score_user_id_fk
       					REFERENCES users ON DELETE CASCADE,
       score				integer,
       creation_date			timestamp
);

-- DROP SEQUENCE ns_user_score_seq;
CREATE SEQUENCE ns_user_score_seq;


--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(

) RETURNS integer AS $$
DECLARE
  foo	integer;
BEGIN

	
  return 0;

END;
$$ LANGUAGE plpgsql;

select inline_0();
drop function inline_0();



