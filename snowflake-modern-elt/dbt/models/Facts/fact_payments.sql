-- Fact payments grain: one row per payment transaction

{{
    config(
        materialized='incremental',
        unique_key='PAYMENT_ID',
        schema='FACTS'
    )
}}

SELECT
    p.PAYMENT_ID,
    p.ORDER_ID,
    p.PAYMENT_DATE,
    TO_NUMBER(TO_CHAR(p.PAYMENT_DATE, 'YYYYMMDD')) AS PAYMENT_DATE_KEY,
    p.PAYMENT_METHOD,
    p.AMOUNT,
    p.CURRENCY,
    p.PAYMENT_STATUS,
    p._LOADED_AT
FROM {{ source('staging', 'STG_PAYMENTS') }} p
{% if is_incremental() %}
WHERE p._LOADED_AT > (SELECT MAX(_LOADED_AT) FROM {{ this }})
{% endif %}
