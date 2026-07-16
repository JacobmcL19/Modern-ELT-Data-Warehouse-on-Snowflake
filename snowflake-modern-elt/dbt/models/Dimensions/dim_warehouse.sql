-- Warehouse dimension

{{
    config(
        materialized='table',
        schema='DIMENSIONS'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['WAREHOUSE_ID']) }} AS WAREHOUSE_SK,
    WAREHOUSE_ID,
    WAREHOUSE_NAME,
    CITY,
    STATE,
    COUNTRY,
    CAPACITY,
    MANAGER_ID
FROM {{ source('staging', 'STG_WAREHOUSES') }}
