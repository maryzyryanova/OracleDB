----------TASK 1----------
DROP TABLE STUDENTS;
DROP TABLE GROUPS;

CREATE TABLE STUDENTS(
    id NUMBER NOT NULL,
    student_name VARCHAR2(100),
    group_id NUMBER
);

CREATE TABLE GROUPS(
    id NUMBER NOT NULL,
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

CREATE OR REPLACE TRIGGER check_unique_student_name_at_groups_trigger
    BEFORE
    UPDATE OR INSERT ON GROUPS
    FOR EACH ROW
    DECLARE
        id_ NUMBER;
        exists_ EXCEPTION;
    BEGIN
        SELECT GROUPS.ID INTO id_ FROM GROUPS WHERE GROUPS.GROUP_name = :NEW.GROUP_name;
            DBMS_OUTPUT.PUT_LINE('The student_name already exists' || :NEW.GROUP_name);
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
CREATE OR REPLACE NONEDITIONABLE TRIGGER new_custom_foreign_key
    AFTER DELETE ON GROUPS
    FOR EACH ROW
    BEGIN
        EXECUTE IMMEDIATE 'DELETE FROM STUDENTS WHERE STUDENTS.group_id = '||:OLD.id;
    END;

DELETE FROM STUDENTS WHERE id = 1;
DELETE FROM GROUPS WHERE id = 2;


----------TASK 4----------
DROP TABLE students_logging;

CREATE TABLE students_logging
(
    id NUMBER PRIMARY KEY,
    operation VARCHAR2(10) NOT NULL,
    date_exec TIMESTAMP NOT NULL,
    new_student_id NUMBER,
    new_student_name VARCHAR2(100),
    new_studenr_group_id NUMBER,
    old_student_id NUMBER,
    old_student_name VARCHAR2(100),
    old_studenr_group_id NUMBER
);

CREATE OR REPLACE TRIGGER student_logger 
AFTER INSERT OR UPDATE OR DELETE 
ON STUDENTS FOR EACH ROW
DECLARE
    TEMP_ID NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM students_logging' INTO TEMP_ID;
    CASE
    WHEN INSERTING THEN
        INSERT INTO students_logging VALUES(TEMP_ID+1, 'INSERT', SYSTIMESTAMP, :new.id, :new.student_name, :new.group_id, NULL, NULL, NULL);
    WHEN UPDATING THEN
        INSERT INTO students_logging VALUES(TEMP_ID+1, 'UPDATE', SYSTIMESTAMP, :new.id, :new.student_name, :new.group_id, :old.id, :old.student_name, :old.group_id);
    WHEN DELETING THEN
        INSERT INTO students_logging VALUES(TEMP_ID+1, 'DELETE', SYSTIMESTAMP, NULL, NULL, NULL, :old.id, :old.student_name, :old.group_id);
    END CASE;
END;

INSERT INTO STUDENTS (student_name, group_id) VALUES ('Dima', 4);
INSERT INTO STUDENTS (student_name, group_id) VALUES('Roman', 4);
UPDATE STUDENTS SET STUDENTS.group_id=5 WHERE STUDENTS.id=7;
DELETE FROM STUDENTS WHERE STUDENTS.id=7;

SELECT * FROM students_logging;


----------TASK 5----------
CREATE OR REPLACE PROCEDURE restore_students(time_back TIMESTAMP) IS
BEGIN
    FOR action IN (SELECT * FROM students_logging WHERE time_back < date_exec ORDER BY id DESC) 
    LOOP
        IF action.operation = 'INSERT' THEN
            DELETE FROM STUDENTS WHERE id = action.new_student_id;
        END IF;
        IF action.operation = 'UPDATE' THEN
            UPDATE STUDENTS SET
            id = action.old_student_id,
            student_name = action.old_student_name,
            group_id = action.old_studenr_group_id
            WHERE id = action.new_student_id;
        END IF;
        IF action.operation = 'DELETE' THEN
            INSERT INTO students VALUES (action.old_student_id, action.old_student_name, action.old_studenr_group_id);
        END IF;
    END LOOP;
END;

SELECT * FROM GROUPS;
SELECT * FROM STUDENTS;

INSERT INTO STUDENTS(student_name, group_id) values('Vanya', 4);
UPDATE STUDENTS SET STUDENTS.group_id=5 WHERE STUDENTS.id=3;
SELECT * FROM students_logging;

DELETE FROM STUDENTS WHERE student_name='Vanya';
EXEC restore_students(TO_TIMESTAMP('09-Feb-02 01.19.05.0000000 PM'));
EXEC restore_students(TO_TIMESTAMP(CURRENT_TIMESTAMP - 45));
EXEC restore_students(TO_TIMESTAMP(CURRENT_TIMESTAMP + numToDSInterval( 1, 'second' )));


----------TASK 6----------
DROP TRIGGER check_unique_student_name_at_groups_trigger;
CREATE OR REPLACE TRIGGER c_val_update
    AFTER INSERT OR UPDATE OR DELETE
    ON STUDENTS
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE id = :new.group_id;
    END IF;
    IF UPDATING THEN
        UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE id = :old.group_id;
        UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE id = :new.group_id;
    END IF;
    IF DELETING THEN
        UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE id = :old.group_id;
    END IF;
END;

INSERT INTO STUDENTS(student_name, group_id) values('001', 4);
INSERT INTO STUDENTS(student_name, group_id) values('002', 5);
INSERT INTO STUDENTS(student_name, group_id) values('003', 5);
INSERT INTO STUDENTS(student_name, group_id) values('004', 6);

UPDATE STUDENTS SET group_id=6 where id=36;
DELETE FROM STUDENTS WHERE id=37;

SELECT * FROM GROUPS;
SELECT * FROM STUDENTS;