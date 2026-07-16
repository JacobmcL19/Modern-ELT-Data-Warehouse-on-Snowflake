-- Dimension date spine covering all order dates

{{
    config(
        materialized='table',
        schema='DIMENSIONS'
    )
}}

WITH date_spine AS (
    SELECT
        DATEADD(DAY, SEQ4(), '2020-01-01'::DATE) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 3650))
)
SELECT
    TO_NUMBER(TO_CHAR(date_day, 'YYYYMMDD'))       AS DATE_KEY,
    date_day                                        AS FULL_DATE,
    YEAR(date_day)                                  AS YEAR,
    QUARTER(date_day)                               AS QUARTER,
    MONTH(date_day)                                 AS MONTH,
    MONTHNAME(date_day)                             AS MONTH_NAME,
    WEEKOFYEAR(date_day)                            AS WEEK_OF_YEAR,
    DAYOFWEEK(date_day)                             AS DAY_OF_WEEK,
    DAYNAME(date_day)                               AS DAY_NAME,
    DAY(date_day)                                   AS DAY_OF_MONTH,
    CASE WHEN DAYOFWEEK(date_day) IN (0, 6) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
    YEAR(date_day) || '-Q' || QUARTER(date_day)     AS YEAR_QUARTER,
    TO_CHAR(date_day, 'YYYY-MM')                    AS YEAR_MONTH
FROM date_spine
