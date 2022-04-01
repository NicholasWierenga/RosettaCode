/*
This will be my submission for the Palindromic Primes task on rosettacode.org
for PL/SQL. The task is to find all palindromic prime numbers below 1000.
PL/SQL isn't need for this and can be done simpler and faster with SQL.
http://rosettacode.org/wiki/Palindromic_primes
*/
CREATE SEQUENCE seq1 INCREMENT BY 1;

CREATE TABLE primelist (
    prime   NUMBER(6),
    tabrows NUMBER(6) DEFAULT seq1.NEXTVAL
);

DECLARE -- This works by filling a table with primes, then removes non-palindromes.
    testpalprime INTEGER(6);
    reverseprime INTEGER(6);
    x            INTEGER(6) := 1;
    rowsremain   INTEGER(6);
    currrow      INTEGER(6);
BEGIN
    FOR n IN 1..1000 LOOP  -- This is to populate the table with primes in a given range.
        FOR y IN 2..n LOOP
            IF y = n THEN
                INSERT INTO primelist ( prime ) VALUES ( n );

            ELSIF n MOD y = 0 THEN
                EXIT;
            END IF;
        END LOOP;
    END LOOP;

    SELECT COUNT(*)
    INTO rowsremain
    FROM primelist;

    SELECT seq1.CURRVAL
    INTO currrow
    FROM dual;

    currrow := currrow - rowsremain + 1;
    WHILE x <= rowsremain LOOP
        SELECT prime,
               reverse(to_char(prime))
        INTO
            testpalprime,
            reverseprime
        FROM primelist
        WHERE tabrows = currrow;

        IF testpalprime <> reverseprime THEN
            DELETE FROM primelist --When a non-palindrome is found, that row is deleted.
            WHERE prime = testpalprime;

            rowsremain := rowsremain - 1;
            x := x - 1; -- Subtracts 1 so no numbers are skipped over.

        END IF;

        x := x + 1;
        currrow := currrow + 1;
    END LOOP;

END; -- What's left in the table are palindromic primes.

SELECT prime AS "Palindromic Primes"
FROM primelist;

DROP SEQUENCE seq1;

DROP TABLE primelist PURGE;
