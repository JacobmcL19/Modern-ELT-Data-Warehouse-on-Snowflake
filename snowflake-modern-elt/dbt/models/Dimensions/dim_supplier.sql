-- Supplier dimension

{{
    config(
        materialized='table',
        schema='DIMENSIONS'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['SUPPLIER_ID']) }} AS SUPPLIER_SK,
    SUPPLIER_ID,
    SUPPLIER_NAME,
    CONTACT_NAME,
    EMAIL,
    PHONE,
    CITY,
    STATE,
    COUNTRY
FROM {{ source('staging', 'STG_SUPPLIERS') }}
