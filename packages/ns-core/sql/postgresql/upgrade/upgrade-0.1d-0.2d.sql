-- upgrade SQL script to rename column names

DROP TABLE ns_mail_weights;
DROP SEQUENCE ns_mail_weights_seq;


CREATE TABLE ns_mail_criteria(
       id				integer
					CONSTRAINT ns_mail_criteria_pk
					PRIMARY KEY,
       mail_id				integer
       					CONSTRAINT ns_mail_criteria_fk
       					REFERENCES iurix_mails ON DELETE CASCADE,
       criteria				varchar(50)
);

CREATE SEQUENCE ns_mail_criteria_seq;

