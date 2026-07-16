{{
    config(
        materialized='view',
        schema='ECOMMERCE'
    )
}}

SELECT
    RETURN_ID,
    ORDER_ID,
    PRODUCT_ID,
    RETURN_DATE,
    RETURN_REASON,
    RETURN_STATUS,
    REFUND_AMOUNT,
    QUANTITY_RETURNED,
    _LOADED_AT
FROM {{ source('raw_ecommerce', 'RAW_RETURNS') }}
