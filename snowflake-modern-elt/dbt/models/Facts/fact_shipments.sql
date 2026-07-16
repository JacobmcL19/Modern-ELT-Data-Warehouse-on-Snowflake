-- Fact shipments grain: one row per shipment

{{
    config(
        materialized='incremental',
        unique_key='SHIPMENT_ID',
        schema='FACTS'
    )
}}

SELECT
    s.SHIPMENT_ID,
    s.ORDER_ID,
    s.WAREHOUSE_ID,
    s.CARRIER,
    s.TRACKING_NUMBER,
    s.SHIP_DATE,
    s.DELIVERY_DATE,
    TO_NUMBER(TO_CHAR(s.SHIP_DATE, 'YYYYMMDD')) AS SHIP_DATE_KEY,
    s.SHIPMENT_STATUS,
    DATEDIFF(DAY, s.SHIP_DATE, s.DELIVERY_DATE) AS TRANSIT_DAYS,
    s._LOADED_AT
FROM {{ source('staging', 'STG_SHIPMENTS') }} s
{% if is_incremental() %}
WHERE s._LOADED_AT > (SELECT MAX(_LOADED_AT) FROM {{ this }})
{% endif %}
