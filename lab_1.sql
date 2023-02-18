DROP TABLE MyTable;

CREATE TABLE MyTable
(
    id  number NOT NULL,
    value number NOT NULL
);

CREATE OR REPLACE FUNCTION TrueOrFalse
    RETURN varchar
IS
    count_odd number := 0;
    count_even number := 0;
    temp number;
    result varchar(10);
BEGIN
    FOR i IN 1 .. 10000
    LOOP
        SELECT MyTable.value INTO temp FROM MyTable WHERE id = i;
        IF temp%2=0 THEN
            count_even := count_even + 1;
        ELSE
            count_odd := count_odd + 1;
        END IF;
    END LOOP;

    IF count_even > count_odd THEN
        result := 'TRUE';
    ELSE IF count_even < count_odd THEN
        result := 'FALSE';
    ELSE
        result := 'EQUAL';
    END IF;
    END IF;
    RETURN result;
END;

ALTER FUNCTION TrueOrFalse COMPILE;

DECLARE
    odd_or_even varchar(10);
BEGIN
    INSERT INTO MyTable
    (id, value)
    SELECT level,ROUND(DBMS_RANDOM.VALUE(1, 10000))
    FROM dual
    CONNECT BY level <= 10000;
    odd_or_even := TRUEORFALSE();
    DBMS_OUTPUT.PUT_LINE(odd_or_even);
END;

SELECT * FROM MyTable;




