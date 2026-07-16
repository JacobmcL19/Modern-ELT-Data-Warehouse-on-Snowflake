{{
    config(
        materialized='view',
        schema='ECOMMERCE'
    )
}}

SELECT
    PAYMENT_ID,
    ORDER_ID,
    PAYMENT_DATE,
    PAYMENT_METHOD,
    AMOUNT,
    CURRENCY,
    PAYMENT_STATUS,
    _LOADED_AT
FROM {{ source('raw_ecommerce', 'RAW_PAYMENTS') }}
