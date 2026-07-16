-- Product dimension with SCD Type 2 support

{{
    config(
        materialized='incremental',
        unique_key='PRODUCT_SK',
        schema='DIMENSIONS'
    )
}}

WITH source AS (
    SELECT
        p.PRODUCT_ID,
        p.PRODUCT_NAME,
        p.SKU,
        p.CATEGORY_ID,
        c.CATEGORY_NAME,
        p.SUPPLIER_ID,
        p.UNIT_PRICE,
        p.COST_PRICE,
        p.UNIT_PRICE - p.COST_PRICE AS PROFIT_MARGIN,
        p.WEIGHT,
        p.IS_ACTIVE,
        p._LOADED_AT
    FROM {{ source('staging', 'STG_PRODUCTS') }} p
    LEFT JOIN {{ source('staging', 'STG_CATEGORIES') }} c
        ON p.CATEGORY_ID = c.CATEGORY_ID
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['PRODUCT_ID', '_LOADED_AT']) }} AS PRODUCT_SK,
    PRODUCT_ID,
    PRODUCT_NAME,
    SKU,
    CATEGORY_ID,
    CATEGORY_NAME,
    SUPPLIER_ID,
    UNIT_PRICE,
    COST_PRICE,
    PROFIT_MARGIN,
    WEIGHT,
    IS_ACTIVE,
    _LOADED_AT AS EFFECTIVE_FROM,
    NULL::TIMESTAMP_NTZ AS EFFECTIVE_TO,
    TRUE AS IS_CURRENT
FROM source
{% if is_incremental() %}
WHERE _LOADED_AT > (SELECT MAX(EFFECTIVE_FROM) FROM {{ this }})
{% endif %}
