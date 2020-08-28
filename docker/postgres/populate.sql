DROP SCHEMA IF EXISTS cop CASCADE;
CREATE SCHEMA cop AUTHORIZATION postgres;
SET search_path = cop;

DROP TABLE IF EXISTS first_names;
DROP TABLE IF EXISTS last_names;

CREATE TABLE first_names (
  id BIGINT PRIMARY KEY,
  first_name VARCHAR(50)
);
CREATE TABLE last_names (
  id BIGINT PRIMARY KEY,
  last_name VARCHAR(50)
);

COPY first_names (id, first_name) FROM '/docker-entrypoint-initdb.d/first_names.csv' DELIMITER ',';
COPY last_names (id, last_name) FROM '/docker-entrypoint-initdb.d/last_names.csv' DELIMITER ',';

DROP TABLE IF EXISTS test_paging;
CREATE TABLE test_paging AS
SELECT ROW_NUMBER() OVER(ORDER BY rnd) AS id, first_name, last_name, age FROM
  (SELECT FLOOR(RANDOM() * 3007 + 1) AS fn, FLOOR(RANDOM() * 473 + 1) AS ln, FLOOR((RANDOM() + RANDOM() + RANDOM()) / 3 * 90)::INT AS age, RANDOM() AS rnd
     FROM generate_series(1, 1000000)) AS d
          JOIN first_names fn ON fn.id = d.fn
          JOIN last_names ln ON ln.id = d.ln;
ALTER TABLE test_paging ADD PRIMARY KEY (id);

CREATE UNIQUE INDEX ix_test_paging_id ON test_paging (id);

CREATE INDEX ix_test_paging_first_name_id ON test_paging (first_name, id);
