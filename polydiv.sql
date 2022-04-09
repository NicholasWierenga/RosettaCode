/*
This will be my submission to Rosettacode.com for the polynomial division task.
The task is to find the quotient of two given polynomials. This code
is incomplete and is being worked on.
*/


CREATE OR REPLACE FUNCTION polydiv (
    bigs IN bigpoly,    -- Since I don't know how large of a polynomial the function will 
    smalls IN smallpoly -- need to handle, we use an array that will contain our polynomial 
) RETURN VARCHAR2 AS    -- and that will be used as our function argument.
    polstring VARCHAR2(2000);
    
    pragma autonomous_transaction;
    
BEGIN
    
    For i IN 1..bigs.count LOOP
        
        IF sign(bigs(i)) = sign(1) AND i <> 1 THEN
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
    
    For i IN 1..smalls.count LOOP
        
        IF sign(smalls(i)) = sign(1) AND i <> 1 THEN
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
        EXECUTE IMMEDIATE 'INSERT INTO divtemp (nums) VALUES(' || bigs(i) || ')';
    END LOOP;
    
    FOR i IN 1..smalls.count LOOP
        EXECUTE IMMEDIATE 'INSERT INTO divtemp (nums) VALUES(' || smalls(i) || ')'; -- test to see if this even matters
    END LOOP;
    
    FOR i IN REVERSE 1..bigs.count LOOP
        FOR j IN REVERSE 1..smalls.count LOOP
        
            IF sign(bigs(i)/smalls(smalls.count) * smalls(j)) = sign(1) AND j = smalls.count THEN
                polstring := polstring || '+';
            END IF;
        
            IF j = smalls.count THEN
                CASE i - j
                    WHEN 0 THEN
                        polstring := polstring || bigs(i)/smalls(smalls.count) * smalls(j);
                    WHEN 1 THEN
                        polstring := polstring || bigs(i)/smalls(smalls.count) * smalls(j) || 'x';
                    ELSE
                        polstring := polstring || bigs(i)/smalls(smalls.count) * smalls(j) || 'x^' || ( i - j - 1 );
                END CASE;
            END IF;
            -- remember that idcol works like a sequence - dropping/truncating the tables won't reset its count, it always increments
            EXECUTE IMMEDIATE 'UPDATE divtemp 
            SET nums = ' || (bigs(i) - bigs(i)/smalls(smalls.count) * smalls(j));
            
        END LOOP;
    END LOOP;
    
    EXECUTE IMMEDIATE 'TRUNCATE TABLE divtemp'; -- We don't need this table again.
    
    
    
    RETURN polstring;
    
END;

CREATE GLOBAL TEMPORARY TABLE divtemp ( 
    nums NUMBER(12, 9),
    idcol NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY
    );


CREATE OR REPLACE TYPE bigpoly AS -- For dividing a poly by another
    TABLE OF NUMBER(12, 9);       -- Increasing the precision allows for larger polynomials 

CREATE OR REPLACE TYPE smallpoly IS
    TABLE OF NUMBER(12, 9);

SELECT * FROM divtemp;
INSERT INTO divtemp (nums) VALUES ( '0');

DROP TABLE divtemp PURGE;

SELECT polydiv(bigpoly(5, 3, 2), smallpoly(3, 1)) FROM dual; 