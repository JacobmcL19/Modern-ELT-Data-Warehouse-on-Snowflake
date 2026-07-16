{{
    config(
        materialized='view',
        schema='ECOMMERCE'
    )
}}

SELECT
    ORDER_ID,
    CUSTOMER_ID,
    ORDER_DATE,
    TO_NUMBER(TO_CHAR(ORDER_DATE, 'YYYYMMDD')) AS ORDER_DATE_KEY,
    REQUIRED_DATE,
    SHIPPED_DATE,
    ORDER_STATUS,
    SHIPPING_METHOD,
    SHIPPING_COST,
    SUBTOTAL,
    TAX_AMOUNT,
    DISCOUNT_AMOUNT,
    TOTAL_AMOUNT,
    WAREHOUSE_ID,
    EMPLOYEE_ID,
    PROMOTION_ID,
    _LOADED_AT
FROM {{ source('raw_ecommerce', 'RAW_ORDERS') }}
