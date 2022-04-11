/*
This will be my submission to Rosettacode.com for the polynomial division task.
The task is to find the quotient of two given polynomials. This code
is incomplete and is being worked on. It can handle the polys below correctly,
but higher power divisors probably don't function correctly.
*/


CREATE OR REPLACE FUNCTION polydiv (
    bigs   IN bigpoly,    -- Since I don't know how large of a polynomial the function will 
    smalls IN smallpoly -- need to handle, we use an array that will contain our polynomial 
) RETURN VARCHAR2 AS    -- and that will be used as our function argument.
    polstring VARCHAR2(2000);
    bigvar1   NUMBER(20, 15);
    bigvar2   NUMBER(20, 15);
    PRAGMA autonomous_transaction; -- check in the end if this is actually needed.

BEGIN
    FOR i IN 1..bigs.count LOOP -- Puts our dividend into the string.

        IF
            sign(bigs(i)) = sign(1) AND length(polstring) <> 0
        THEN -- The string length is to insure a leading "+" does not occur.
            polstring := polstring || '+';
        END IF;

        CASE i
            WHEN 1 THEN
                polstring := polstring || bigs(i);
            WHEN 2 THEN
                polstring := polstring || bigs(i) || 'x';
            ELSE
                polstring := polstring || bigs(i) || 'x^' || ( i - 1 );
        END CASE;

        IF abs(bigs(i)) = 1 THEN -- To make terms like +-1x^n appear as +-x^n.
            CASE i
                WHEN 1 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(bigs(i)) + 2);
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(abs(bigs(i)) || 'x')) || 'x';
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(abs(bigs(i)) || 'x^' ||(i - 1))) || 'x^' || ( i - 1 );
            END CASE;
        ELSIF bigs(i) = 0 THEN
            CASE i -- Used to avoid functions like 1+3x+2x^2+0x^3+0x^4 from resulting in something like 1+3x+2x^2x^3x^4
                WHEN 1 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(bigs(i)));
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(bigs(i) || 'x'));
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(bigs(i) || 'x^' ||(i - 1)));
            END CASE;
        END IF;

    END LOOP;

    polstring := polstring || ' / ';
    FOR i IN 1..smalls.count LOOP -- Puts our divisor into the string.

        IF sign(smalls(i)) = sign(1) THEN
            polstring := polstring || '+';
        END IF;

        CASE i
            WHEN 1 THEN
                polstring := polstring || smalls(i);
            WHEN 2 THEN
                polstring := polstring || smalls(i) || 'x';
            ELSE
                polstring := polstring || smalls(i) || 'x^' || ( i - 1 );
        END CASE;

        IF abs(smalls(i)) = 1 THEN -- To make terms like +-1x^n appear as +-x^n.
            CASE i
                WHEN 1 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(smalls(i)) + 2);
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(abs(smalls(i)) || 'x')) || 'x';
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(abs(smalls(i)) || 'x^' ||(i - 1))) || 'x^' || ( i - 1 );
            END CASE;
        ELSIF smalls(i) = 0 THEN
            CASE i -- Used to avoid functions like 1+3x+2x^2+0x^3+0x^4 from resulting in something like 1+3x+2x^2x^3x^4
                WHEN 1 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(smalls(i)));
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(smalls(i) || 'x'));
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(smalls(i) || 'x^' ||(i - 1)));
            END CASE;
        END IF;

    END LOOP;

    polstring := polstring || ' = ';
    FOR i IN 1..bigs.count LOOP
        EXECUTE IMMEDIATE 'INSERT INTO divtemp VALUES(' || bigs(i) || ' , ' || i || ')';
    END LOOP;

    FOR i IN REVERSE 1..bigs.count LOOP -- Puts our quotient into the string.

        SELECT nums
        INTO bigvar1
        FROM divtemp
        WHERE idcol = i;

        FOR j IN REVERSE 1..smalls.count LOOP -- maybe switch back to 1 from i

            bigvar2 := smalls.count; -- We can't put smalls.count in the line below without an error, so we use this to hold that value.
            SELECT nums
            INTO bigvar2
            FROM divtemp
            WHERE idcol = ( i - bigvar2 + j );

            IF
                sign(bigvar1 / smalls(smalls.count) * smalls(j)) = sign(1) AND j = smalls.count
            THEN -- A divide by 0 error could occur here if the quotient is lead by a 0.
                polstring := polstring || '+';                                                    -- Consider getting another variable or use an if statement.
            END IF;

            IF j = smalls.count THEN
                CASE i - j
                    WHEN 0 THEN
                        polstring := polstring || bigvar1 / smalls(smalls.count) * smalls(j);
                    WHEN 1 THEN
                        polstring := polstring || bigvar1 / smalls(smalls.count) * smalls(j) || 'x';
                    ELSE
                        polstring := polstring || bigvar1 / smalls(smalls.count) * smalls(j) || 'x^' || ( i - j );
                END CASE;
            END IF;

            IF
                bigvar1 / smalls(smalls.count) * smalls(j) = 0 AND j = smalls.count
            THEN
                CASE i - j -- Used to avoid functions like 1+3x+2x^2+0x^3+0x^4 from resulting in something like 1+3x+2x^2x^3x^4
                    WHEN 0 THEN
                        polstring := substr(polstring, 1, length(polstring) - length(bigvar1 / smalls(smalls.count) * smalls(j)));
                    WHEN 1 THEN
                        polstring := substr(polstring, 1, length(polstring) - length(bigvar1 / smalls(smalls.count) * smalls(j) || 'x'));
                    ELSE
                        polstring := substr(polstring, 1, length(polstring) - length(bigvar1 / smalls(smalls.count) * smalls(j) || 'x^' ||(
                        i - j)));
                END CASE;
            END IF;

            IF abs(bigvar1 / smalls(smalls.count) * smalls(j)) = 1 THEN -- To make terms like +-1x^n appear as +-x^n.
                CASE i - j
                    WHEN 0 THEN
                        polstring := substr(polstring, 1, length(polstring) - length(bigvar1 / smalls(smalls.count) * smalls(j)) + 2);
                    WHEN 1 THEN
                        polstring := substr(polstring, 1, length(polstring) - length(abs(bigvar1 / smalls(smalls.count) * smalls(j)) ||
                        'x')) || 'x';
                    ELSE
                        polstring := substr(polstring, 1, length(polstring) - length(abs(bigvar1 / smalls(smalls.count) * smalls(j)) ||
                        'x^' ||(i - 1))) || 'x^' || ( i - j );
                END CASE;
            END IF;

            EXECUTE IMMEDIATE 'UPDATE divtemp 
            SET nums = ' || ( bigvar2 - bigvar1 / smalls(smalls.count) * smalls(j) ) || ' WHERE  idcol = ' || ( i - 2 + j );

        END LOOP;

        IF i = smalls.count THEN
            EXIT;
        END IF;
    END LOOP;

    polstring := polstring || ', Remainder: ';
    FOR i IN smalls.count - 1..bigs.count LOOP -- Puts our remainder in the string.
    -- maybe change range if remainder is off. 1..bigs.count works, but much of the data from the table is just zeroes, which we don't care to show.
        SELECT nums
        INTO bigvar1
        FROM divtemp
        WHERE idcol = i;

        IF sign(bigvar1) = sign(1) THEN
            polstring := polstring || '+';
        END IF;

        CASE i
            WHEN 1 THEN
                polstring := polstring || bigvar1;
            WHEN 2 THEN
                polstring := polstring || bigvar1 || 'x';
            ELSE
                polstring := polstring || bigvar1 || 'x^' || ( i - 1 );
        END CASE;

        IF abs(bigvar1) = 1 THEN -- To make terms like +-1x^n appear as +-x^n.
            CASE i
                WHEN 1 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(bigvar1) + 2);
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(abs(bigvar1) || 'x')) || 'x';
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(abs(bigvar1) || 'x^' ||(i - 1))) || 'x^' || ( i - 1 );
            END CASE;
        ELSIF bigvar1 = 0 THEN
            CASE i -- Used to avoid functions like 1+3x+2x^2+0x^3+0x^4 from resulting in something like 1+3x+2x^2x^3x^4
                WHEN 1 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(bigvar1));
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(bigvar1 || 'x'));
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(bigvar1 || 'x^' ||(i - 1)));
            END CASE;
        END IF;

    END LOOP;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE divtemp'; -- Might be able to do delete * to not have any commits done

    RETURN replace(polstring, ' +', ' ') || '.'; -- Gets rid of trailing + if they're there.

END;

CREATE GLOBAL TEMPORARY TABLE divtemp ( -- Change around data types to increase input poly size potential and result accuracy.
    nums  NUMBER(32, 15),
    idcol INTEGER
);

CREATE OR REPLACE TYPE bigpoly AS -- For dividing a poly by another
    TABLE OF NUMBER(32, 25);      -- Increasing the precision allows for larger polynomials 

CREATE OR REPLACE TYPE smallpoly IS
    TABLE OF NUMBER(32, 25);

DROP TABLE divtemp PURGE;

SELECT polydiv(bigpoly(0, 5, 3, 0, 2, 1), smallpoly(3, 1)) AS "test inputs" FROM dual -- Still need to fix errors that may come from negatives or larger divisors
UNION ALL                                                                             -- and case where the input is the zero polynomial, divide by zero, 
SELECT polydiv(bigpoly(0, 1, 1, 0, 9, 3), smallpoly(3, 1)) FROM dual                  -- and implement a return for dividing a poly by a larger poly.        
UNION ALL
SELECT polydiv(bigpoly(0, 0, 0, 0, 0, 1), smallpoly(3, 1)) FROM dual
UNION ALL
SELECT polydiv(bigpoly(0, 0, 3, 0, 0, 0), smallpoly(3, 1)) FROM dual
UNION ALL
SELECT polydiv(bigpoly(0, 0, 0, 0, 0, 1, 0, 0, 0, 3), smallpoly(3, 1)) FROM dual -- An error(precision too large) occurs if input when there is a high-powered polynomial.
UNION ALL                                                                        -- Precision can be increased to increase poly size, but polys quickly become too large to handle.
SELECT polydiv(bigpoly(1, 2, 3, 0, 3, 1), smallpoly(3, 1)) FROM dual             -- Lowering scale also allows for larger polys too be handled. A data type other than NUMBER might be preferable.
UNION ALL
SELECT polydiv(bigpoly(2, 5, 3, 1, 2, 1), smallpoly(3, 1))
FROM dual;
