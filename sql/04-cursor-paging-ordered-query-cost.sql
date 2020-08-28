SET search_path = cop;

CREATE OR REPLACE FUNCTION cursor_paging_ordered_query_cost(OUT counter integer,
                                                            OUT cost double precision,
                                                            OUT duration double precision) RETURNS SETOF record
	LANGUAGE 'plpgsql'
	STRICT AS
$$
DECLARE
	p              json;
	field          varchar(50) := '';
	id             bigint      := 0;
	offset_current int         := 9;
BEGIN
	counter := 0;
	LOOP
		EXIT WHEN counter > 500000;
		EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) SELECT * FROM test_paging WHERE (first_name, id) >= ($1, $2) ORDER BY first_name, id LIMIT 12' INTO p USING field, id;
		EXECUTE 'SELECT first_name, id FROM test_paging WHERE (first_name, id) >= ($1, $2) ORDER BY first_name, id OFFSET $3 LIMIT 1' INTO field, id USING field, id, offset_current;
		SELECT p -> 0 -> 'Plan' ->> 'Total Cost',
		       p -> 0 -> 'Plan' ->> 'Actual Total Time'
		INTO cost, duration;
		RETURN NEXT;
		counter := counter + 10;
		offset_current := 10;
	END LOOP;
END;
$$;

COPY (SELECT * FROM cursor_paging_ordered_query_cost()) TO '/var/lib/postgresql/data/cursor_paging_ordered_query_cost.csv' WITH csv DELIMITER ';';
