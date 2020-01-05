
-- References: https://tableplus.io/blog/2018/04/postgresql-import-csv-file-to-a-table.html
COPY table_name FROM ‘/path_to_csv_file.csv’ WITH FORMAT csv;
