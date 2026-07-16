{{
    config(
        materialized='view',
        schema='ECOMMERCE'
    )
}}

SELECT
    PRODUCT_ID,
    TRIM(PRODUCT_NAME)    AS PRODUCT_NAME,
    CATEGORY_ID,
    SUBCATEGORY,
    BRAND,
    SUPPLIER_ID,
    UNIT_PRICE,
    UNIT_COST,
    (UNIT_PRICE - UNIT_COST) AS MARGIN,
    WEIGHT_KG,
    IS_ACTIVE,
    LAUNCH_DATE,
    DISCONTINUE_DATE,
    SKU,
    _LOADED_AT
FROM {{ source('raw_ecommerce', 'RAW_PRODUCTS') }}
