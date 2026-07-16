-- Northwind Commerce: Raw table definitions for all source entities


/*
=============================================================================
  RAW TABLES - Landing zone for ingested source data
  These tables accept data as-is from source systems with minimal typing.
=============================================================================
*/

USE DATABASE NORTHWIND_RAW;
USE SCHEMA ECOMMERCE;

-- ============================================================================
-- CUSTOMERS
-- ============================================================================

CREATE OR REPLACE TABLE RAW_CUSTOMERS (
    CUSTOMER_ID         VARCHAR(50)     NOT NULL,
    FIRST_NAME          VARCHAR(100),
    LAST_NAME           VARCHAR(100),
    EMAIL               VARCHAR(255),
    PHONE               VARCHAR(50),
    DATE_OF_BIRTH       DATE,
    GENDER              VARCHAR(20),
    ADDRESS_LINE1       VARCHAR(255),
    ADDRESS_LINE2       VARCHAR(255),
    CITY                VARCHAR(100),
    STATE               VARCHAR(50),
    POSTAL_CODE         VARCHAR(20),
    COUNTRY             VARCHAR(100),
    CUSTOMER_SEGMENT    VARCHAR(50),
    REGISTRATION_DATE   TIMESTAMP_NTZ,
    IS_ACTIVE           BOOLEAN,
    LOYALTY_TIER        VARCHAR(20),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Raw customer records from ecommerce platform';

-- ============================================================================
-- PRODUCTS
-- ============================================================================

CREATE OR REPLACE TABLE RAW_PRODUCTS (
    PRODUCT_ID          VARCHAR(50)     NOT NULL,
    PRODUCT_NAME        VARCHAR(500),
    CATEGORY_ID         VARCHAR(50),
    SUBCATEGORY         VARCHAR(100),
    BRAND               VARCHAR(100),
    SUPPLIER_ID         VARCHAR(50),
    UNIT_PRICE          NUMBER(10,2),
    UNIT_COST           NUMBER(10,2),
    WEIGHT_KG           NUMBER(8,3),
    IS_ACTIVE           BOOLEAN,
    LAUNCH_DATE         DATE,
    DISCONTINUE_DATE    DATE,
    SKU                 VARCHAR(50),
    DESCRIPTION         VARCHAR(2000),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Raw product catalog from inventory system';

-- ============================================================================
-- CATEGORIES
-- ============================================================================

CREATE OR REPLACE TABLE RAW_CATEGORIES (
    CATEGORY_ID         VARCHAR(50)     NOT NULL,
    CATEGORY_NAME       VARCHAR(100),
    PARENT_CATEGORY_ID  VARCHAR(50),
    DESCRIPTION         VARCHAR(500),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Product category hierarchy';

-- ============================================================================
-- ORDERS
-- ============================================================================

CREATE OR REPLACE TABLE RAW_ORDERS (
    ORDER_ID            VARCHAR(50)     NOT NULL,
    CUSTOMER_ID         VARCHAR(50)     NOT NULL,
    ORDER_DATE          TIMESTAMP_NTZ,
    REQUIRED_DATE       DATE,
    SHIPPED_DATE        TIMESTAMP_NTZ,
    ORDER_STATUS        VARCHAR(30),
    SHIPPING_METHOD     VARCHAR(50),
    SHIPPING_COST       NUMBER(10,2),
    SUBTOTAL            NUMBER(12,2),
    TAX_AMOUNT          NUMBER(10,2),
    DISCOUNT_AMOUNT     NUMBER(10,2),
    TOTAL_AMOUNT        NUMBER(12,2),
    WAREHOUSE_ID        VARCHAR(50),
    EMPLOYEE_ID         VARCHAR(50),
    PROMOTION_ID        VARCHAR(50),
    NOTES               VARCHAR(1000),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Raw sales orders from ecommerce platform';

-- ============================================================================
-- ORDER LINE ITEMS (embedded in orders for denormalized loading)
-- ============================================================================

CREATE OR REPLACE TABLE RAW_ORDER_ITEMS (
    ORDER_ITEM_ID       VARCHAR(50)     NOT NULL,
    ORDER_ID            VARCHAR(50)     NOT NULL,
    PRODUCT_ID          VARCHAR(50)     NOT NULL,
    QUANTITY            NUMBER(10,0),
    UNIT_PRICE          NUMBER(10,2),
    DISCOUNT_PERCENT    NUMBER(5,2),
    LINE_TOTAL          NUMBER(12,2),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Order line items linked to orders and products';

-- ============================================================================
-- PAYMENTS
-- ============================================================================

CREATE OR REPLACE TABLE RAW_PAYMENTS (
    PAYMENT_ID          VARCHAR(50)     NOT NULL,
    ORDER_ID            VARCHAR(50)     NOT NULL,
    PAYMENT_DATE        TIMESTAMP_NTZ,
    PAYMENT_METHOD      VARCHAR(50),
    AMOUNT              NUMBER(12,2),
    CURRENCY            VARCHAR(10),
    PAYMENT_STATUS      VARCHAR(30),
    TRANSACTION_REF     VARCHAR(100),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Payment transactions for orders';

-- ============================================================================
-- RETURNS
-- ============================================================================

CREATE OR REPLACE TABLE RAW_RETURNS (
    RETURN_ID           VARCHAR(50)     NOT NULL,
    ORDER_ID            VARCHAR(50)     NOT NULL,
    PRODUCT_ID          VARCHAR(50)     NOT NULL,
    RETURN_DATE         TIMESTAMP_NTZ,
    RETURN_REASON       VARCHAR(200),
    RETURN_STATUS       VARCHAR(30),
    REFUND_AMOUNT       NUMBER(10,2),
    QUANTITY_RETURNED   NUMBER(10,0),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Product returns and refunds';

-- ============================================================================
-- SHIPMENTS
-- ============================================================================

CREATE OR REPLACE TABLE RAW_SHIPMENTS (
    SHIPMENT_ID         VARCHAR(50)     NOT NULL,
    ORDER_ID            VARCHAR(50)     NOT NULL,
    WAREHOUSE_ID        VARCHAR(50),
    CARRIER             VARCHAR(100),
    TRACKING_NUMBER     VARCHAR(100),
    SHIP_DATE           TIMESTAMP_NTZ,
    DELIVERY_DATE       TIMESTAMP_NTZ,
    SHIPMENT_STATUS     VARCHAR(30),
    SHIPPING_COST       NUMBER(10,2),
    WEIGHT_KG           NUMBER(8,3),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Shipment tracking data from logistics';

-- ============================================================================
-- SUPPLIERS
-- ============================================================================

CREATE OR REPLACE TABLE RAW_SUPPLIERS (
    SUPPLIER_ID         VARCHAR(50)     NOT NULL,
    SUPPLIER_NAME       VARCHAR(200),
    CONTACT_NAME        VARCHAR(100),
    CONTACT_EMAIL       VARCHAR(255),
    PHONE               VARCHAR(50),
    ADDRESS             VARCHAR(500),
    CITY                VARCHAR(100),
    STATE               VARCHAR(50),
    COUNTRY             VARCHAR(100),
    POSTAL_CODE         VARCHAR(20),
    PAYMENT_TERMS       VARCHAR(50),
    LEAD_TIME_DAYS      NUMBER(5,0),
    RATING              NUMBER(3,1),
    IS_ACTIVE           BOOLEAN,
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Supplier master data';

-- ============================================================================
-- WAREHOUSES
-- ============================================================================

CREATE OR REPLACE TABLE RAW_WAREHOUSES (
    WAREHOUSE_ID        VARCHAR(50)     NOT NULL,
    WAREHOUSE_NAME      VARCHAR(200),
    WAREHOUSE_TYPE      VARCHAR(50),
    ADDRESS             VARCHAR(500),
    CITY                VARCHAR(100),
    STATE               VARCHAR(50),
    COUNTRY             VARCHAR(100),
    POSTAL_CODE         VARCHAR(20),
    CAPACITY_UNITS      NUMBER(10,0),
    MANAGER_ID          VARCHAR(50),
    IS_ACTIVE           BOOLEAN,
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Warehouse and distribution center master data';

-- ============================================================================
-- INVENTORY
-- ============================================================================

CREATE OR REPLACE TABLE RAW_INVENTORY (
    INVENTORY_ID        VARCHAR(50)     NOT NULL,
    PRODUCT_ID          VARCHAR(50)     NOT NULL,
    WAREHOUSE_ID        VARCHAR(50)     NOT NULL,
    QUANTITY_ON_HAND    NUMBER(10,0),
    QUANTITY_RESERVED   NUMBER(10,0),
    REORDER_POINT       NUMBER(10,0),
    REORDER_QUANTITY    NUMBER(10,0),
    LAST_RESTOCK_DATE   DATE,
    UNIT_COST           NUMBER(10,2),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Current inventory levels by product and warehouse';

-- ============================================================================
-- EMPLOYEES
-- ============================================================================

CREATE OR REPLACE TABLE RAW_EMPLOYEES (
    EMPLOYEE_ID         VARCHAR(50)     NOT NULL,
    FIRST_NAME          VARCHAR(100),
    LAST_NAME           VARCHAR(100),
    EMAIL               VARCHAR(255),
    PHONE               VARCHAR(50),
    HIRE_DATE           DATE,
    DEPARTMENT          VARCHAR(100),
    JOB_TITLE           VARCHAR(100),
    MANAGER_ID          VARCHAR(50),
    WAREHOUSE_ID        VARCHAR(50),
    SALARY              NUMBER(12,2),
    IS_ACTIVE           BOOLEAN,
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Employee records from HR system';

-- ============================================================================
-- PROMOTIONS
-- ============================================================================

CREATE OR REPLACE TABLE RAW_PROMOTIONS (
    PROMOTION_ID        VARCHAR(50)     NOT NULL,
    PROMOTION_NAME      VARCHAR(200),
    PROMOTION_TYPE      VARCHAR(50),
    DISCOUNT_PERCENT    NUMBER(5,2),
    DISCOUNT_AMOUNT     NUMBER(10,2),
    START_DATE          DATE,
    END_DATE            DATE,
    MIN_ORDER_VALUE     NUMBER(10,2),
    IS_ACTIVE           BOOLEAN,
    APPLICABLE_CATEGORIES VARCHAR(500),
    _LOADED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE        VARCHAR(500)
)
COMMENT = 'Marketing promotions and discount campaigns';
