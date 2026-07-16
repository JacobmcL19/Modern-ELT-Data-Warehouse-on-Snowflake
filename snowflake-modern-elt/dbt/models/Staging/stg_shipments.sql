{{
    config(
        materialized='view',
        schema='ECOMMERCE'
    )
}}

SELECT
    SHIPMENT_ID,
    ORDER_ID,
    WAREHOUSE_ID,
    CARRIER,
    TRACKING_NUMBER,
    SHIP_DATE,
    DELIVERY_DATE,
    SHIPMENT_STATUS,
    SHIPPING_COST,
    WEIGHT_KG,
    DATEDIFF(DAY, SHIP_DATE, DELIVERY_DATE) AS TRANSIT_DAYS,
    _LOADED_AT
FROM {{ source('raw_ecommerce', 'RAW_SHIPMENTS') }}
WHERE SHIP_DATE IS NOT NULL
