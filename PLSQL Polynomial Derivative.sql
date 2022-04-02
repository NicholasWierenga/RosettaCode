/*
This will be my submission for the Polynomial Derivative task on rosettacode.org
for PL/SQL. The task is to find the derivative of a polynomial given as an ordered
list of its coefficients by increasing power of x. For example, an input of the form
(3, -2, 5, 0, 2) represents the polynomial 3-2x+5x^2+2x^4.

The task requires testing only polynomials of at most degree 4, but this code can 
handle much higher. Much of the code is also just trying to format its output.
Because of this, a far more concise code that still satisfies the requirement of
the task can be made in this language.
*/

CREATE OR REPLACE TYPE coeff AS
    TABLE OF NUMBER(12, 9); -- Increasing the precision allows for larger polynomials 
                            -- to be derived, scale increases accuracy with decimals.

CREATE OR REPLACE FUNCTION polyderiv (
    nums IN coeff -- Since I don't know how large of a polynomial the function will 
) RETURN VARCHAR AS -- need to handle we use an array that will contain our polynomial 
    polstring VARCHAR(2000); -- and that will be used as our function argument.
BEGIN
    polstring := 'Original polynomial: ';
    FOR i IN 1..nums.count LOOP -- Check to see if we have the zero polynomial.
        EXIT WHEN nums(i) <> 0;
        IF i = nums.count THEN
            RETURN 'Original polynomial: 0. Its derivative is: 0.';
        END IF;
    END LOOP;

    FOR i IN 1..nums.count LOOP
        IF sign(nums(i)) = sign(1) THEN
            polstring := polstring || '+';
        END IF;

        CASE i
            WHEN 1 THEN
                polstring := polstring || nums(i);
            WHEN 2 THEN
                polstring := polstring || nums(i) || 'x';
            ELSE
                polstring := polstring || nums(i) || 'x^' || ( i - 1 );
        END CASE;

        IF abs(nums(i)) = 1 THEN -- To make terms like +-1x^n appear as +-x^n.
            CASE i
                WHEN 1 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(nums(i)) + 2);
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(abs(nums(i)) || 'x')) || 'x';
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(abs(nums(i)) || 'x^' ||(i - 1))) || 'x^' || ( i - 1 );
            END CASE;
        ELSIF nums(i) = 0 THEN
            CASE i -- Used to avoid functions like 1+3x+2x^2+0x^3+0x^4 from resulting in something like 1+3x+2x^2x^3x^4
                WHEN 1 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(nums(i)));
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(nums(i) || 'x'));
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(nums(i) || 'x^' ||(i - 1)));
            END CASE;
        END IF;

    END LOOP;

    polstring := polstring || '. ' || 'Its derivative is: ';
    
    IF nums.count = 1 THEN -- Checks if the derived polynomial would be the zero polynomial.
        RETURN replace(polstring, ' +', ' ') || '0.';
    END IF;
    
    
    FOR i IN 2..nums.count LOOP -- Derives the polynomial and concats it onto polstring

        IF sign(nums(i)) = sign(1) THEN
            polstring := polstring || '+';
        END IF;

        CASE i
            WHEN 2 THEN
                polstring := polstring || ( i - 1 ) * nums(i);
            WHEN 3 THEN
                polstring := polstring || ( i - 1 ) * nums(i) || 'x';
            ELSE
                polstring := polstring || ( i - 1 ) * nums(i) || 'x^' || ( i - 2 );
        END CASE;

        IF abs((i - 1) * nums(i)) = 1 THEN -- To make terms like +-1x^n appear as +-x^n.
            CASE i
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length((i - 1) * nums(i)) + 2);
                WHEN 3 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(abs((i - 1) * nums(i))) - 1) || 'x';
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(abs((i - 1) * nums(i)) || 'x^' ||(i - 1))) || 'x^' || (
                    i - 2 );
            END CASE;
        ELSIF nums(i) = 0 THEN
            CASE i
                WHEN 2 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(nums(i)));
                WHEN 3 THEN
                    polstring := substr(polstring, 1, length(polstring) - length(nums(i) || 'x'));
                ELSE
                    polstring := substr(polstring, 1, length(polstring) - length(nums(i) || 'x^' ||(i - 2)));
            END CASE;
        END IF;

    END LOOP;

    SELECT replace(polstring, ' +', ' ')
    INTO polstring
    FROM dual; -- Gets rid of trailing + if they're there.

    RETURN polstring;
END;



SELECT polyderiv(coeff(0)) FROM dual -- Zero polynomial functions fine.
UNION ALL
SELECT polyderiv(coeff(0, 0, 0, 0, 0, 0)) FROM dual
UNION ALL
SELECT polyderiv(coeff(1, 3, -2, 2, - 4)) FROM dual
UNION ALL
SELECT polyderiv(coeff(- 1, 1, -.5, 4, - 5)) FROM dual
UNION ALL
SELECT polyderiv(coeff(1, 1,.5, 1/3, - 1/4)) FROM dual -- Due to rounding, sometimes we have errors.
UNION ALL
SELECT polyderiv(coeff(0, 3)) FROM dual
UNION ALL
SELECT polyderiv(coeff(-1, 2, 0)) FROM dual
UNION ALL
SELECT polyderiv(coeff(1, 1, 2, -2, 4, 32, 6, 11, 0, 0, 0, 1)) -- Large polynomials can be used.
FROM dual
UNION ALL
SELECT polyderiv(coeff(-1, 1, 1, 1, 1, -1, -1, 0, 0, 0, 0, 0))
FROM dual;

-- These are the polynomials given from the task below.
SELECT polyderiv(coeff(5)) FROM dual
UNION ALL
SELECT polyderiv(coeff(4, -3)) FROM dual
UNION ALL
SELECT polyderiv(coeff(1, 6, 5)) FROM dual
UNION ALL
SELECT polyderiv(coeff(4, 3, -2)) FROM dual
UNION ALL
SELECT polyderiv(coeff(1, 1, -1, -1)) FROM dual;