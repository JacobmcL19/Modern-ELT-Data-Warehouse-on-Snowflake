-- Fact returns grain: one row per return

{{
    config(
        materialized='incremental',
        unique_key='RETURN_ID',
        schema='FACTS'
    )
}}

SELECT
    r.RETURN_ID,
    r.ORDER_ID,
    r.PRODUCT_ID,
    r.RETURN_DATE,
    TO_NUMBER(TO_CHAR(r.RETURN_DATE, 'YYYYMMDD')) AS RETURN_DATE_KEY,
    r.REASON,
    r.REFUND_AMOUNT,
    r.RETURN_STATUS,
    r._LOADED_AT
FROM {{ source('staging', 'STG_RETURNS') }} r
{% if is_incremental() %}
WHERE r._LOADED_AT > (SELECT MAX(_LOADED_AT) FROM {{ this }})
{% endif %}
