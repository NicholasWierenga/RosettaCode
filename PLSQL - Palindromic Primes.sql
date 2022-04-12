/*
This will be my submission for the Palindromic Primes task on rosettacode.org
for PLSQL. The task is to find all palindromic prime numbers below 1000.
PLSQL isn't need for this and can be done with SQL with not too much of a slowdown.
http://rosettacode.org/wiki/Palindromic_primes
*/

CREATE TABLE numlist (
    nums INTEGER
);

INSERT INTO numlist ( nums )
    SELECT ROWNUM
    FROM col$ -- Pick some large-rowed table and cross join to it to itself.
    CROSS JOIN (
        SELECT ROWNUM
        FROM col$
        FETCH FIRST 100 ROWS ONLY)
    FETCH FIRST 5500000 ROWS ONLY; -- It took around a minute to sort through 5.5 million.

DECLARE
    prime INTEGER := 0;
BEGIN
    DELETE FROM numlist
    WHERE nums = 1;

    WHILE prime IS NOT NULL LOOP
        
        EXECUTE IMMEDIATE 'DELETE FROM numlist
        WHERE mod(nums, ' || prime || ') = 0 AND ' || prime || ' <> nums
        OR nums <> reverse(to_char(nums))'; -- Deletes all numbers that have prime as a factor and any non-palindromes.

        SELECT MIN(nums)
        INTO prime
        FROM numlist
        WHERE nums > prime; -- We pick the next number in the table, 
                            -- which is prime due to it not being deleted by all previous primes used.

    END LOOP;

END;

SELECT nums AS "Palindromic Primes"
FROM numlist;

DROP TABLE numlist PURGE;
