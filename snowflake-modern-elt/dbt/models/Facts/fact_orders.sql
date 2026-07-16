-- Fact orders grain: one row per order

{{
    config(
        materialized='incremental',
        unique_key='ORDER_ID',
        schema='FACTS'
    )
}}

SELECT
    o.ORDER_ID,
    o.CUSTOMER_ID,
    o.ORDER_DATE_KEY,
    o.ORDER_DATE,
    o.REQUIRED_DATE,
    o.SHIPPED_DATE,
    o.ORDER_STATUS,
    o.SHIPPING_METHOD,
    o.SHIPPING_COST,
    o.SUBTOTAL,
    o.TAX_AMOUNT,
    o.DISCOUNT_AMOUNT,
    o.TOTAL_AMOUNT,
    o.WAREHOUSE_ID,
    o.EMPLOYEE_ID,
    o.PROMOTION_ID,
    DATEDIFF(DAY, o.ORDER_DATE, o.SHIPPED_DATE) AS DAYS_TO_SHIP,
    DATEDIFF(DAY, o.ORDER_DATE, o.REQUIRED_DATE) AS DAYS_TO_REQUIRED,
    o._LOADED_AT
FROM {{ source('staging', 'STG_ORDERS') }} o
{% if is_incremental() %}
WHERE o._LOADED_AT > (SELECT MAX(_LOADED_AT) FROM {{ this }})
{% endif %}
