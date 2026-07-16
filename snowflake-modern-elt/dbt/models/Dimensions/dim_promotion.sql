-- Promotion dimension

{{
    config(
        materialized='table',
        schema='DIMENSIONS'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['PROMOTION_ID']) }} AS PROMOTION_SK,
    PROMOTION_ID,
    PROMOTION_NAME,
    DISCOUNT_TYPE,
    DISCOUNT_VALUE,
    START_DATE,
    END_DATE,
    IS_ACTIVE,
    CASE WHEN CURRENT_DATE() BETWEEN START_DATE AND END_DATE THEN TRUE ELSE FALSE END AS IS_CURRENT_PROMO
FROM {{ source('staging', 'STG_PROMOTIONS') }}
