-- /packages/imp-core/sql/postgresql/imp-core-create.sql

CREATE TABLE imp_parties (
       party_id		 integer
       			 PRIMARY KEY,
       legal_name	 varchar(200),
       cnpj		 varchar(100),
       state_registry	 varchar(100),
       type		 varchar(50)
);

-- imp_parties.type manufacturer, exporter, importer

CREATE TABLE imp_orders (
       order_id		integer
       			PRIMARY KEY,
       importer_id	integer
       			CONSTRAINT orders_importer_id_fk
			REFERENCES imp_parties ON DELETE CASCADE,
       exporter_id	integer
       			CONSTRAINT orders_importer_id_fk
			REFERENCES imp_parties ON DELETE CASCADE,
       manufacturer_id	integer
       			CONSTRAINT orders_importer_id_fk
			REFERENCES imp_parties ON DELETE CASCADE
);
