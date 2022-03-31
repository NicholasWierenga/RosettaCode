SET SERVEROUTPUT ON;

CREATE TABLE primelist (
    prime   NUMBER(6),
    tabrows NUMBER(6) DEFAULT seq1.NEXTVAL
);

CREATE SEQUENCE seq1 INCREMENT BY 1;
  
/*
This will be my submission for the Palindromic Primes task on rosettacode.org. This
is currently unsolved for PL/SQL. The task is, find all palindromic prime numbers
below 1000. http://rosettacode.org/wiki/Palindromic_primes
*/

DECLARE -- This is to populate the table with primes in a given range.
    primenum INTEGER(6);
BEGIN
    FOR n IN 1..1000 LOOP
        FOR y IN 2..n LOOP
            IF y = n THEN
                primenum := n;
                INSERT INTO primelist ( prime ) VALUES ( primenum );

            ELSIF n MOD y = 0 THEN
                EXIT;
            END IF;
        END LOOP;
    END LOOP;
END;

DECLARE -- This filters through our table for palindromes.
    testpalprime INTEGER(6);
    x            INTEGER(6) := 1;
    rowsremain   INTEGER(6);
    currrow      INTEGER(6);
BEGIN
    SELECT COUNT(*)
    INTO rowsremain
    FROM primelist;

    SELECT seq1.CURRVAL
    INTO currrow
    FROM dual;

    currrow := currrow - rowsremain + 1;
    WHILE x <= rowsremain LOOP
        SELECT prime
        INTO testpalprime
        FROM primelist
        WHERE tabrows = currrow;

        FOR c IN 1..ceil(length(testpalprime) / 2) LOOP
            IF substr(testpalprime, c, 1) != substr(testpalprime, -c, 1) THEN
                DELETE FROM primelist
                WHERE prime = testpalprime;

                x := x - 1;
                EXIT; --When a non-palindrome is found, that row is deleted.

            END IF;
        END LOOP;

        x := x + 1;
        currrow := currrow + 1;
        SELECT COUNT(*)
        INTO rowsremain
        FROM primelist;

    END LOOP;

END; -- What's left in the table are palindromic primes.

SELECT prime AS "Palindromic Primes"
FROM primelist;

DROP SEQUENCE seq1;

DROP TABLE primelist;