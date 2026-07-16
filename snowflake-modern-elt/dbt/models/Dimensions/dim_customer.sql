-- Customer dimension with SCD Type 2 support

{{
    config(
        materialized='incremental',
        unique_key='CUSTOMER_SK',
        schema='DIMENSIONS'
    )
}}

WITH source AS (
    SELECT
        CUSTOMER_ID,
        FIRST_NAME,
        LAST_NAME,
        FULL_NAME,
        EMAIL,
        PHONE,
        DATE_OF_BIRTH,
        AGE,
        GENDER,
        ADDRESS_LINE1,
        CITY,
        STATE,
        POSTAL_CODE,
        COUNTRY,
        CUSTOMER_SEGMENT,
        REGISTRATION_DATE,
        IS_ACTIVE,
        LOYALTY_TIER,
        _LOADED_AT
    FROM {{ source('staging', 'STG_CUSTOMERS') }}
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['CUSTOMER_ID', '_LOADED_AT']) }} AS CUSTOMER_SK,
    CUSTOMER_ID,
    FIRST_NAME,
    LAST_NAME,
    FULL_NAME,
    EMAIL,
    PHONE,
    DATE_OF_BIRTH,
    AGE,
    GENDER,
    ADDRESS_LINE1,
    CITY,
    STATE,
    POSTAL_CODE,
    COUNTRY,
    CUSTOMER_SEGMENT,
    REGISTRATION_DATE,
    IS_ACTIVE,
    LOYALTY_TIER,
    _LOADED_AT AS EFFECTIVE_FROM,
    NULL::TIMESTAMP_NTZ AS EFFECTIVE_TO,
    TRUE AS IS_CURRENT
FROM source
{% if is_incremental() %}
WHERE _LOADED_AT > (SELECT MAX(EFFECTIVE_FROM) FROM {{ this }})
{% endif %}
