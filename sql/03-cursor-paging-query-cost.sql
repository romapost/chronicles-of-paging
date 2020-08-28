SET search_path = cop;

CREATE OR REPLACE FUNCTION cursor_paging_query_cost(OUT counter integer,
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
		EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) SELECT * FROM test_paging WHERE id >= $1 ORDER BY id LIMIT 12' INTO p USING counter;
		SELECT p -> 0 -> 'Plan' ->> 'Total Cost',
		       p -> 0 -> 'Plan' ->> 'Actual Total Time'
		INTO cost, duration;
		RETURN NEXT;
		counter := counter + 100;
	END LOOP;
END;
$$;

COPY (SELECT * FROM cursor_paging_query_cost()) TO '/var/lib/postgresql/data/cursor_paging_query_cost.csv' WITH csv DELIMITER ';';
