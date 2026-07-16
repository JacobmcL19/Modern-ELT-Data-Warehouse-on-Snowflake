{{
    config(
        materialized='view',
        schema='ECOMMERCE'
    )
}}

SELECT
    CUSTOMER_ID,
    TRIM(FIRST_NAME)                            AS FIRST_NAME,
    TRIM(LAST_NAME)                             AS LAST_NAME,
    TRIM(FIRST_NAME) || ' ' || TRIM(LAST_NAME) AS FULL_NAME,
    LOWER(TRIM(EMAIL))                          AS EMAIL,
    PHONE,
    DATE_OF_BIRTH,
    DATEDIFF(YEAR, DATE_OF_BIRTH, CURRENT_DATE()) AS AGE,
    GENDER,
    ADDRESS_LINE1,
    CITY,
    UPPER(STATE)                                AS STATE,
    POSTAL_CODE,
    COUNTRY,
    CUSTOMER_SEGMENT,
    REGISTRATION_DATE,
    IS_ACTIVE,
    LOYALTY_TIER,
    _LOADED_AT
FROM {{ source('raw_ecommerce', 'RAW_CUSTOMERS') }}
