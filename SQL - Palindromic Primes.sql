/*
This will be my submission for the Palindromic Primes task on rosettacode.org
for SQL. The task is to find all palindromic prime numbers below 1000.
http://rosettacode.org/wiki/Palindromic_primes
*/
CREATE TABLE primelist (
    nums NUMBER(6)
);

INSERT INTO primelist ( nums )
    SELECT ROWNUM
    FROM col$ -- Pick some large-rowed table or start cross joining if you need more rows for some reason.
    FETCH FIRST 1000 ROWS ONLY; -- Change to expand range.

DELETE FROM primelist a 
WHERE EXISTS ( -- We use a correlated subquery to delete non-primes.
    SELECT b.nums 
    FROM primelist b
    WHERE mod(a.nums, b.nums) = 0 AND a.nums > b.nums AND b.nums <> 1
) OR a.nums = 1;

SELECT nums AS "Palindromic Primes" -- Takes the primes and searches for the palindromes.
FROM primelist
WHERE nums = reverse(to_char(nums));

DROP TABLE primelist PURGE;
