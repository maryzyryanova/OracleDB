----------TASK 1----------

DROP TABLE STUDENTS;
DROP TABLE GROUPS;

CREATE TABLE STUDENTS(
    id NUMBER,
    student_name VARCHAR2(100),
    group_id NUMBER
);

CREATE TABLE GROUPS(
    id NUMBER,
    group_name VARCHAR2(100),
    c_val NUMBER
);


----------TASK 2----------
DROP SEQUENCE STUDENTS_SEQUENCE;
DROP SEQUENCE GROUPS_SEQUENCE;

CREATE SEQUENCE students_sequence
    START WITH 1    
    INCREMENT BY 1
    NOMAXVALUE;

CREATE SEQUENCE groups_sequence
    START WITH 1    
    INCREMENT BY 1
    NOMAXVALUE;

CREATE OR REPLACE TRIGGER check_unique_id_at_students_trigger
    BEFORE
    INSERT ON STUDENTS
    FOR EACH ROW
    DECLARE
        id_ NUMBER;
        exists_ EXCEPTION;
    BEGIN
        SELECT STUDENTS.ID INTO id_ FROM STUDENTS WHERE STUDENTS.ID = :NEW.ID;
            DBMS_OUTPUT.PUT_LINE('The id already exists' || :NEW.ID);
            raise exists_;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Successfully inserted!');
    END;

CREATE OR REPLACE TRIGGER check_unique_id_at_groups_trigger
    BEFORE
    INSERT ON GROUPS
    FOR EACH ROW
    DECLARE
        id_ NUMBER;
        exists_ EXCEPTION;
    BEGIN
        SELECT GROUPS.ID INTO id_ FROM GROUPS WHERE GROUPS.ID = :NEW.ID;
            DBMS_OUTPUT.PUT_LINE('The id already exists' || :NEW.ID);
            raise exists_;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Successfully inserted!');
    END;

CREATE OR REPLACE TRIGGER generate_students_id_trigger
    BEFORE
    INSERT ON STUDENTS 
    FOR EACH ROW
    BEGIN
        SELECT students_sequence.NEXTVAL
        INTO :new.id
        FROM DUAL;
    END;

CREATE OR REPLACE TRIGGER generate_groups_id_trigger
    BEFORE
    INSERT ON GROUPS
    FOR EACH ROW
    BEGIN
        SELECT groups_sequence.NEXTVAL
        INTO :new.id
        FROM DUAL;
    END;

CREATE OR REPLACE TRIGGER check_unique_name_at_groups_trigger
    BEFORE
    UPDATE OR INSERT ON GROUPS
    FOR EACH ROW
    DECLARE
        id_ NUMBER;
        exists_ EXCEPTION;
    BEGIN
        SELECT GROUPS.ID INTO id_ FROM GROUPS WHERE GROUPS.GROUP_NAME = :NEW.GROUP_NAME;
            DBMS_OUTPUT.PUT_LINE('The name already exists' || :NEW.GROUP_NAME);
            raise exists_;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Successfully inserted!');
    END;

INSERT INTO STUDENTS (student_name, group_id) VALUES ('Katya', 3);
INSERT INTO STUDENTS (student_name, group_id) VALUES ('Lesha', 2);
INSERT INTO STUDENTS (student_name, group_id) VALUES ('Nastya', 1);
INSERT INTO STUDENTS (student_name, group_id) VALUES ('Dasha', 3);
INSERT INTO STUDENTS (student_name, group_id) VALUES ('Nikita', 2);

INSERT INTO GROUPS(group_name, c_val) VALUES('053501', 0);
INSERT INTO GROUPS(group_name, c_val) VALUES('053502', 0);
INSERT INTO GROUPS(group_name, c_val) VALUES('053503', 0);
INSERT INTO GROUPS(group_name, c_val) VALUES('053504', 0);
INSERT INTO GROUPS(group_name, c_val) VALUES('053505', 0);
INSERT INTO GROUPS(group_name, c_val) VALUES('053505', 0);

SELECT * FROM STUDENTS;
SELECT * FROM GROUPS;


----------TASK 3----------

CREATE OR REPLACE TRIGGER custom_foreign_key
    AFTER DELETE ON GROUPS
    FOR EACH ROW
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TRIGGER custom_foreign_key DISABLE';
        EXECUTE IMMEDIATE 'DELETE FROM STUDENTS WHERE STUDENTS.group_id = '||:OLD.id;
        EXECUTE IMMEDIATE 'ALTER TRIGGER custom_foreign_key ENABLE';
    END;

DELETE FROM STUDENTS WHERE id = 1;
DELETE FROM GROUPS WHERE id = 2;

----------TASK 4----------


----------TASK 5----------


----------TASK 6----------