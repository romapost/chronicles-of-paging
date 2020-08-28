SET search_path = cop;

CREATE OR REPLACE FUNCTION offset_paging_query_cost(OUT counter integer,
                                                    OUT cost double precision,
                                                    OUT duration double precision) RETURNS SETOF record
	LANGUAGE 'plpgsql'
	STRICT AS
$$
DECLARE
	p json;
BEGIN
	counter = 0;
	LOOP
		EXIT WHEN counter = 500000;
		EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) SELECT * FROM test_paging LIMIT 10 OFFSET $1' INTO p USING counter;
		SELECT p -> 0 -> 'Plan' ->> 'Total Cost',
		       p -> 0 -> 'Plan' ->> 'Actual Total Time'
		INTO cost, duration;
		RETURN NEXT;
		counter := counter + 100;
	END LOOP;
END;
$$;

COPY (SELECT * FROM offset_paging_query_cost()) TO '/var/lib/postgresql/data/offset_paging_query_cost.csv' WITH csv DELIMITER ';';
