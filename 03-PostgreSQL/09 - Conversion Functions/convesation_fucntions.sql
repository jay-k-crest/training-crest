/*
- TOPIC 1: TO_CHAR FUNCTION
- Purpose: Converts various data types (timestamp, interval, integer, etc.) to formatted strings.
- Syntax: TO_CHAR(value, 'format_pattern').
- Date Formatting: Use patterns like 'YYYY-MM-DD', 'HH24:MI:SS', or 'Month' for full month names.
- Numeric Formatting: Use '9' for digits and '0' for leading zeros (e.g., '$9,999.99').
- Use Case: Essential for creating human-readable reports or matching specific display requirements.
*/


/*
- FORMATTING PATTERNS FOR TO_CHAR
- Date/Time Patterns:
    - YYYY / YY: 4-digit or 2-digit year.
    - MONTH / Month / mon: Full uppercase, capitalized, or abbreviated month.
    - MM: Month number (01-12).
    - DAY / Day / dy: Full uppercase, capitalized, or abbreviated day name.
    - DD: Day of month (01-31).
    - HH24 / HH12: Hour in 24-hour or 12-hour format.
    - MI: Minutes (00-59).
    - SS: Seconds (00-59).
    - AM / PM: Meridian indicator.

- Numeric/Digit Patterns:
    - 9: Digit position (omits leading zeros).
    - 0: Digit position (forces leading/trailing zeros).
    - . (period): Decimal point location.
    - , (comma): Group (thousands) separator.
    - PR: Negative value in angle brackets.
    - L: Currency symbol (based on locale).
    - MI: Minus sign in specified position (for negative numbers).
*/

--int to string
select
    to_char(
        100870,
        '9,99999'
    );

select 
    release_date,
    to_char(release_date,'DD-MM-YYYY'),
    to_char(release_date,'Dy-MM-YYYY')
from movies;

--converting timestamp to string 

select
    to_char(
        timestamp '2020-01-01 10:30:56',
        'HH24:MI:SS'
    )

--adding $ sign to revenues_domestic 

select
    to_char(
        revenues_domestic,
        '$999,999,999.9999'
    )
from movies_revenues;


/*
- TOPIC 2: TO_NUMBER FUNCTION (DETAILED)
- Purpose: Parses a string and converts it to a NUMERIC type based on a specific template.
- Syntax: TO_NUMBER(text, format_mask).

- ADVANCED FORMATTING TECHNIQUES:
    - Digit Handling: 
        - '999': Represents the max digits; if the string has fewer, it still works.
        - '000': Forces the function to look for leading zeros.
    - Currency & Signs:
        - 'L': Used to strip locale-specific currency symbols (like $ or £) during conversion.
        - 'SG': Handles the 'Plus/Minus' sign at the start or end of the string.
        - 'PR': Allows parsing of numbers wrapped in brackets, which represent negative values (e.g., '(100)').
    - Grouping: 
        - 'G' or ',': Used to skip over thousands separators so they don't break the numeric conversion.
    - Decimals:
        - 'D' or '.': Tells PostgreSQL exactly where the fractional part begins.

- CAUTION: Unlike a simple CAST, TO_NUMBER is rigid. If your format mask doesn't 
  account for a character (like a stray space or symbol), the function will throw an error.
*/

--str to number
select to_number(
    '123,456.78', '999,999.99'   
);

select to_number(
    '10,625.78-', '99G999D99MI'
);

select to_number(
    '$1,420.64', 'L9G999D99'
);

SELECT 
 to_number(
    '1,234,567.89' , '9G999G999D99'
 )

--converting say money number

SELECT
 to_number('$123.45', 'L999D99');


/*
- TOPIC 3: TO_DATE FUNCTION
- Purpose: Converts a string (text) into a DATE type based on a specific template.
- Syntax: TO_DATE('string', 'format_pattern').

- KEY FORMATTING PATTERNS:
    - YYYY: 4-digit year (e.g., '2024').
    - MM: Month number (01–12).
    - Month/Mon: Full name (January) or abbreviated name (Jan).
    - DD: Day of the month (01–31).
    - DDD: Day of the year (001–366).
    - WW: Week number of the year.

- BEHAVIOR & RULES:
    - Strictness: The string must match the pattern. '2024-05-01' needs 'YYYY-MM-DD'.
    - Overspecification: If you provide time details (like HH:MI:SS), TO_DATE ignores them 
      and only returns the date. Use TO_TIMESTAMP if you need the time.
    - Defaulting: If a year is not provided, it defaults to the current year.
*/


--string to date

SELECT to_date(
    '2024-01-01', 'YYYY-MM-DD'
);

SELECT to_date(
'022199','MMDDYY'
);

SELECT to_date(
'march 07,2019', 'month dd,yyyy'
);

--error handling 
--will generate error
SELECT to_date(
 '2020/02/30' , 'YYYY/MM/DD'
);



/*
- TOPIC 4: TO_TIMESTAMP FUNCTION
- Purpose: Converts a string to a TIMESTAMPTZ (timestamp with time zone).
- Syntax: TO_TIMESTAMP('string', 'format_pattern').

- EXTENDED PATTERNS:
    - HH24 / HH12: 24-hour clock (00-23) or 12-hour clock (01-12).
    - MI: Minutes (00-59).
    - SS: Seconds (00-59).
    - MS / US: Milliseconds (3 digits) or Microseconds (6 digits).
    - AM / PM: Meridian indicators (used with HH12).
    - TZH / TZM: Time zone hour and time zone minute offsets.

- KEY CHARACTERISTICS:
    - Precision: Unlike TO_DATE, this preserves the exact time down to seconds/milliseconds.
    - Time Zone: If no zone is in the string, it uses the current 'TimeZone' setting of your database.
    - Robustness: It can handle complex strings like '2026-Jan-20 17:30:05'.
*/


select to_timestamp(
 '2020-10-28 10:28:30' , 'YYYY-MM-DD HH24:MI:SS'
);

--it skips spaces
select to_timestamp(
 '2020       may','yyyy mon'
);




--minimal error checking is there

select to_timestamp(
 '2020-10-28 32:28:30', 'YYYY-MM-DD HH24:MI:SS'
);
--will generate error 

select to_timestamp(
 '2020-10-28 10:28:30', 'YYYY-MM-DD HH24:MI:SS'
);
