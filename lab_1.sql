DROP TABLE MyTable;

CREATE TABLE MyTable
(
    id  number NOT NULL,
    val number NOT NULL
);

CREATE OR REPLACE PROCEDURE UpdateTable(new_id number, val_new number) 
IS
BEGIN
    UPDATE MYTABLE
    SET val = val_new
    WHERE id = new_id;

EXCEPTION
    WHEN OTHERS THEN
    raise_application_error(SQLCODE,'No such id');

END UpdateTable;

CREATE OR REPLACE PROCEDURE InsertIntoTable(id_num number, val_new number) IS
    ind number;
BEGIN
    SELECT COUNT(*) INTO ind FROM MyTable WHERE ID = id_num;
    DBMS_OUTPUT.PUT_LINE(ind);
    IF ind=0 THEN
        INSERT INTO MYTABLE
        VALUES(id_num, val_new);
    ELSE
        UPDATE MYTABLE
        SET val = val_new
        WHERE id = id_num;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
    raise_application_error(SQLCODE,'No such id');

END InsertIntoTable;

CREATE OR REPLACE PROCEDURE DeleteFromTable(val_new number) 
IS
BEGIN
    DELETE FROM MYTABLE
    WHERE val < val_new;
END DeleteFromTable;

CREATE OR REPLACE FUNCTION TrueOrFalse
    RETURN varchar
IS
    count_odd number := 0;
    count_even number := 0;
    temp number;
    res varchar(10);
BEGIN
    FOR i IN 1 .. 10
    LOOP
        SELECT val INTO temp FROM MyTable WHERE id = i;
        IF REMAINDER(temp, 2) = 0 THEN
            count_even := count_even + 1;
        ELSE
            count_odd := count_odd + 1;
        END IF;
    END LOOP;

    IF count_even > count_odd THEN
        res := 'TRUE';
    ELSE IF count_even < count_odd THEN
        res := 'FALSE';
    ELSE
        res := 'EQUAL';
    END IF;
    END IF;
    RETURN res;
END;

CREATE OR REPLACE FUNCTION PrintInsert(id_num number)
    RETURN varchar
IS
    ind number;
    temp number;
    res varchar(100);
BEGIN 
    SELECT COUNT(*) INTO ind FROM MyTable WHERE ID = id_num;
    IF ind=0 THEN
        res := 'Error! This index does not exist!';
    ELSE
        SELECT MyTable.VAL INTO temp FROM MyTable WHERE MyTable.ID = id_num;
        res := 'INSERT INTO MyTable VALUES(' || id_num || ', ' || temp || ');';
        DBMS_OUTPUT.PUT_LINE(id_num);
    END IF;
    RETURN res;
END;

CREATE OR REPLACE FUNCTION Reward(salary INTEGER, bonus INTEGER)
    RETURN REAL
IS
    p REAL;
    percent_error EXCEPTION;
    PRAGMA exception_init(percent_error, -20001 );
    negative_salary_error EXCEPTION;
    PRAGMA exception_init(negative_salary_error, -20002 );
BEGIN
    IF salary < 0 THEN
        RAISE negative_salary_error;
    END IF;
    IF bonus < 0 or bonus > 100 THEN
        RAISE percent_error;
    END IF;
    p := bonus / 100;
    RETURN (1 + p) * 12 * salary;
EXCEPTION
    WHEN negative_salary_error THEN
    raise_application_error(-20001,'Salary must be >=0');
    WHEN percent_error THEN
    raise_application_error(-20002,'Percent must be between 0 and 100');
END;

ALTER FUNCTION TrueOrFalse COMPILE;
ALTER FUNCTION PrintInsert COMPILE;
ALTER FUNCTION Reward COMPILE;

BEGIN
    INSERT INTO MyTable
    (id, val)
    SELECT level, ROUND(DBMS_RANDOM.VALUE(1, 10))
    FROM dual
    CONNECT BY level <= 10;
    DBMS_OUTPUT.PUT_LINE(TRUEORFALSE());
END;
   
BEGIN
    DBMS_OUTPUT.PUT_LINE(PRINTINSERT(1));
    DBMS_OUTPUT.PUT_LINE(Reward(2, 3));
END;

EXECUTE InsertIntoTable(11, 5);
EXECUTE UpdateTable(11, 9);
EXECUTE DeleteFromTable(11, 2);

SELECT * FROM MyTable;