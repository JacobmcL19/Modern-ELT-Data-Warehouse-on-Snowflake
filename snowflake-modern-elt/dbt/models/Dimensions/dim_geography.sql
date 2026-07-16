-- Geography dimension derived from customer addresses

{{
    config(
        materialized='table',
        schema='DIMENSIONS'
    )
}}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['CITY', 'STATE', 'COUNTRY']) }} AS GEOGRAPHY_SK,
    CITY,
    STATE,
    COUNTRY
FROM {{ source('staging', 'STG_CUSTOMERS') }}
WHERE CITY IS NOT NULL
