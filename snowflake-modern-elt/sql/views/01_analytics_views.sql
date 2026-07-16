-- Northwind Commerce: Analytics views for dashboard consumption


/*
=============================================================================
  ANALYTICS VIEWS
  Pre-built views for Streamlit dashboard and business reporting.
=============================================================================
*/

USE DATABASE NORTHWIND_DW;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- EXECUTIVE KPIs
-- ============================================================================

CREATE OR REPLACE VIEW V_EXECUTIVE_SUMMARY AS
SELECT
    DATE_TRUNC('MONTH', o.ORDER_DATE)::DATE          AS MONTH,
    COUNT(DISTINCT o.ORDER_ID)                       AS TOTAL_ORDERS,
    COUNT(DISTINCT o.CUSTOMER_ID)                    AS UNIQUE_CUSTOMERS,
    SUM(o.TOTAL_AMOUNT)                              AS TOTAL_REVENUE,
    SUM(o.TOTAL_AMOUNT - o.SHIPPING_COST - o.TAX_AMOUNT) AS GROSS_PROFIT,
    AVG(o.TOTAL_AMOUNT)                              AS AVG_ORDER_VALUE,
    SUM(o.DISCOUNT_AMOUNT)                           AS TOTAL_DISCOUNTS,
    COUNT(DISTINCT CASE WHEN o.ORDER_STATUS = 'Delivered' THEN o.ORDER_ID END) AS DELIVERED_ORDERS,
    COUNT(DISTINCT CASE WHEN o.ORDER_STATUS = 'Cancelled' THEN o.ORDER_ID END) AS CANCELLED_ORDERS
FROM NORTHWIND_STAGING.ECOMMERCE.STG_ORDERS o
GROUP BY 1
ORDER BY 1;

-- ============================================================================
-- CUSTOMER ANALYTICS
-- ============================================================================

CREATE OR REPLACE VIEW V_CUSTOMER_LIFETIME_VALUE AS
SELECT
    c.CUSTOMER_ID,
    c.FULL_NAME,
    c.CUSTOMER_SEGMENT,
    c.LOYALTY_TIER,
    c.REGISTRATION_DATE,
    COUNT(DISTINCT o.ORDER_ID)                       AS TOTAL_ORDERS,
    SUM(o.TOTAL_AMOUNT)                              AS LIFETIME_REVENUE,
    AVG(o.TOTAL_AMOUNT)                              AS AVG_ORDER_VALUE,
    MIN(o.ORDER_DATE)                                AS FIRST_ORDER_DATE,
    MAX(o.ORDER_DATE)                                AS LAST_ORDER_DATE,
    DATEDIFF(DAY, MIN(o.ORDER_DATE), MAX(o.ORDER_DATE)) AS CUSTOMER_TENURE_DAYS,
    CASE WHEN COUNT(DISTINCT o.ORDER_ID) > 1 THEN TRUE ELSE FALSE END AS IS_REPEAT_CUSTOMER
FROM NORTHWIND_STAGING.ECOMMERCE.STG_CUSTOMERS c
LEFT JOIN NORTHWIND_STAGING.ECOMMERCE.STG_ORDERS o ON c.CUSTOMER_ID = o.CUSTOMER_ID
GROUP BY 1, 2, 3, 4, 5;

-- ============================================================================
-- PRODUCT PERFORMANCE
-- ============================================================================

CREATE OR REPLACE VIEW V_PRODUCT_PERFORMANCE AS
SELECT
    p.PRODUCT_ID,
    p.PRODUCT_NAME,
    p.CATEGORY_ID,
    p.BRAND,
    p.UNIT_PRICE,
    p.UNIT_COST,
    (p.UNIT_PRICE - p.UNIT_COST)                     AS MARGIN_PER_UNIT,
    COUNT(DISTINCT oi.ORDER_ID)                      AS TIMES_ORDERED,
    SUM(oi.QUANTITY)                                  AS TOTAL_QUANTITY_SOLD,
    SUM(oi.LINE_TOTAL)                               AS TOTAL_REVENUE,
    SUM(oi.QUANTITY * p.UNIT_COST)                   AS TOTAL_COST,
    SUM(oi.LINE_TOTAL) - SUM(oi.QUANTITY * p.UNIT_COST) AS TOTAL_PROFIT
FROM NORTHWIND_RAW.ECOMMERCE.RAW_PRODUCTS p
LEFT JOIN NORTHWIND_RAW.ECOMMERCE.RAW_ORDER_ITEMS oi ON p.PRODUCT_ID = oi.PRODUCT_ID
GROUP BY 1, 2, 3, 4, 5, 6, 7;

-- ============================================================================
-- SHIPPING PERFORMANCE
-- ============================================================================

CREATE OR REPLACE VIEW V_SHIPPING_METRICS AS
SELECT
    s.CARRIER,
    s.SHIPMENT_STATUS,
    COUNT(*)                                          AS SHIPMENT_COUNT,
    AVG(DATEDIFF(DAY, s.SHIP_DATE, s.DELIVERY_DATE)) AS AVG_DELIVERY_DAYS,
    AVG(s.SHIPPING_COST)                             AS AVG_SHIPPING_COST,
    SUM(CASE WHEN s.SHIPMENT_STATUS = 'Delivered' THEN 1 ELSE 0 END)::FLOAT
        / NULLIF(COUNT(*), 0)                        AS DELIVERY_RATE
FROM NORTHWIND_RAW.ECOMMERCE.RAW_SHIPMENTS s
WHERE s.SHIP_DATE IS NOT NULL
GROUP BY 1, 2;

-- ============================================================================
-- INVENTORY STATUS
-- ============================================================================

CREATE OR REPLACE VIEW V_INVENTORY_STATUS AS
SELECT
    i.WAREHOUSE_ID,
    w.WAREHOUSE_NAME,
    i.PRODUCT_ID,
    p.PRODUCT_NAME,
    p.BRAND,
    i.QUANTITY_ON_HAND,
    i.QUANTITY_RESERVED,
    (i.QUANTITY_ON_HAND - i.QUANTITY_RESERVED)        AS AVAILABLE_QUANTITY,
    i.REORDER_POINT,
    CASE WHEN i.QUANTITY_ON_HAND <= i.REORDER_POINT THEN TRUE ELSE FALSE END AS NEEDS_REORDER,
    i.LAST_RESTOCK_DATE,
    DATEDIFF(DAY, i.LAST_RESTOCK_DATE, CURRENT_DATE()) AS DAYS_SINCE_RESTOCK
FROM NORTHWIND_RAW.ECOMMERCE.RAW_INVENTORY i
JOIN NORTHWIND_RAW.ECOMMERCE.RAW_WAREHOUSES w ON i.WAREHOUSE_ID = w.WAREHOUSE_ID
JOIN NORTHWIND_RAW.ECOMMERCE.RAW_PRODUCTS p ON i.PRODUCT_ID = p.PRODUCT_ID;

-- ============================================================================
-- RETURN ANALYSIS
-- ============================================================================

CREATE OR REPLACE VIEW V_RETURN_ANALYSIS AS
SELECT
    r.RETURN_REASON,
    r.RETURN_STATUS,
    COUNT(*)                                          AS RETURN_COUNT,
    SUM(r.REFUND_AMOUNT)                             AS TOTAL_REFUNDED,
    AVG(r.REFUND_AMOUNT)                             AS AVG_REFUND,
    AVG(DATEDIFF(DAY, o.ORDER_DATE, r.RETURN_DATE))  AS AVG_DAYS_TO_RETURN
FROM NORTHWIND_RAW.ECOMMERCE.RAW_RETURNS r
JOIN NORTHWIND_RAW.ECOMMERCE.RAW_ORDERS o ON r.ORDER_ID = o.ORDER_ID
GROUP BY 1, 2;
