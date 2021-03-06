-- /packages/iurix-mails/sql/postgresql/upgrade/upgrade-0.4d-0.5d.sql

SELECT acs_log__debug('/packages/iurix-mails/sql/postgresql/upgrade/upgrade-0.4d-0.5d.sql', '');



ALTER TABLE iurix_mails DROP CONSTRAINT iurix_mails_mail_id_fk;

ALTER TABLE iurix_mails ADD CONSTRAINT iurix_mails_mail_id_fk FOREIGN KEY (mail_id) REFERENCES cr_revisions (revision_id) ON DELETE CASCADE;


CREATE OR REPLACE FUNCTION iurix_mails__update (
       integer,	  	   -- mail_id
       integer,	  	   -- package_id
       integer,	    	   -- user_id
       varchar,	    	   -- type
       varchar,	    	   -- subject
       text,	    	   -- bodies
       varchar(255), 	   -- date
       varchar(255),	   -- to
       varchar(255),	   -- from
       varchar(255),	   -- delivered_to
       varchar(255),	   -- importance
       text,		   -- dkim_signature
       text,		   -- headers
       text,		   -- message_id
       text,		   -- received
       varchar(255),	   -- return_path
       varchar(255),	   -- x_mailer
       varchar(255),	   -- x_original_to
       varchar(255),	   -- x_arrival_time
       varchar(255),	   -- x_originating_ip
       varchar(255)	   -- x_priority
) RETURNS integer AS '
  DECLARE
	p_mail_id		ALIAS FOR $1;
	p_package_id		ALIAS FOR $2;
       	p_user_id		ALIAS FOR $3;
	p_type			ALIAS FOR $4;
	p_subject	      	ALIAS FOR $5;
	p_bodies	      	ALIAS FOR $6;
	p_date		      	ALIAS FOR $7;
	p_to_address	      	ALIAS FOR $8;
	p_from_address	      	ALIAS FOR $9;
	p_delivered_to	      	ALIAS FOR $10;
	p_importance	      	ALIAS FOR $11;
	p_dkim_signature      	ALIAS FOR $12;
	p_headers		ALIAS FOR $13;
	p_message_id		ALIAS FOR $14;
	p_received		ALIAS FOR $15;
	p_return_path		ALIAS FOR $16;
	p_x_mailer		ALIAS FOR $17;
	p_x_original_to		ALIAS FOR $18;
	p_x_arrival_time	ALIAS FOR $19;
       	p_x_originating_ip	ALIAS FOR $20;
	p_x_priority		ALIAS FOR $21;
	
  BEGIN
	
  	UPDATE iurix_mails SET 
	       package_id = p_package_id,
	       user_id = p_user_id,
	       type = p_type,
	       subject = p_subject,
	       bodies = p_bodies,
	       date = p_date,
	       to_address = p_to_address,
	       from_address = p_from_address,
	       delivered_to = p_delivered_to,
	       importance = p_importance,
	       dkim_signature = p_dkim_signature,
	       headers = p_headers,
	       message_id = p_message_id,
	       received = p_received,
	       return_path = p_return_path,
	       x_mailer = p_x_mailer,
	       x_original_to = p_x_original_to,
	       x_arrival_time = p_x_arrival_time,
	       x_originating_ip = p_x_originating_ip,
	       x_priority = p_x_priority
	WHERE  mail_id = p_mail_id;

	RETURN 0;

  END' language 'plpgsql';
