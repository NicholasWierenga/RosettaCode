/*
This is my attempt at the Palindromic Primes task on rosettacode.org
for SQL. The task is to find all palindromic prime numbers below 1000.
This code is relatively fast, but struggles when the table is large, due to
the subquery.
http://rosettacode.org/wiki/Palindromic_primes
*/
CREATE TABLE numlist (
    nums INTEGER
);

INSERT INTO numlist ( nums )
    SELECT ROWNUM
    FROM col$
    CROSS JOIN (SELECT ROWNUM FROM col$ FETCH FIRST 100 ROWS ONLY)
    FETCH FIRST 1800000 ROWS ONLY; -- Making numlist larger than it needs to be raises query time a lot.

SELECT nums AS "Palindromic Primes"
FROM numlist a
WHERE NOT EXISTS (SELECT b.nums 
    FROM numlist b
    WHERE mod(a.nums, b.nums) = 0 AND a.nums > b.nums AND b.nums <> 1) AND a.nums <> 1  -- Checks if a.nums is prime.
    AND nums = reverse(to_char(nums)) -- Checks if we have a palindrome.
    AND a.nums BETWEEN 1 and 1800000; -- Defines our range.

DROP TABLE numlist PURGE;

-- 1.8 million rows took about a minute to sort through. Another way exists  
-- involving PLSQL that works far faster can be found here:
-- https://github.com/NicholasWierenga/RosettaCode/blob/main/SQL%20-%20Palindromic%20Primes.sql
