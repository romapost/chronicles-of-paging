SET search_path = cop;

CREATE OR REPLACE FUNCTION offset_paging_ordered_query_cost(IN field varchar,
                                                            OUT counter integer,
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
		EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) SELECT * FROM test_paging ORDER BY $1, id LIMIT 10 OFFSET $2' INTO p USING field, counter;
		SELECT p -> 0 -> 'Plan' ->> 'Total Cost',
		       p -> 0 -> 'Plan' ->> 'Actual Total Time'
		INTO cost, duration;
		RETURN NEXT;
		counter := counter + 100;
	END LOOP;
END;
$$;

COPY (SELECT * FROM offset_paging_ordered_query_cost('first_name')) TO '/var/lib/postgresql/data/offset_paging_index_ordered_query_cost.csv' WITH csv DELIMITER ';';
COPY (SELECT * FROM offset_paging_ordered_query_cost('last_name')) TO '/var/lib/postgresql/data/offset_paging_ordered_query_cost.csv' WITH csv DELIMITER ';';
