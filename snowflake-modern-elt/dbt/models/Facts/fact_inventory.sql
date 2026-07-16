-- Fact inventory snapshot grain: one row per product-warehouse

{{
    config(
        materialized='table',
        schema='FACTS'
    )
}}

SELECT
    i.INVENTORY_ID,
    i.PRODUCT_ID,
    i.WAREHOUSE_ID,
    i.QUANTITY_ON_HAND,
    i.REORDER_POINT,
    i.LAST_RESTOCK_DATE,
    CASE WHEN i.QUANTITY_ON_HAND <= i.REORDER_POINT THEN TRUE ELSE FALSE END AS NEEDS_REORDER,
    i._LOADED_AT
FROM {{ source('staging', 'STG_INVENTORY') }} i
