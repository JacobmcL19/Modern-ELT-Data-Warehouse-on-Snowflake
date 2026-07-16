-- Northwind Commerce: Database and warehouse infrastructure setup


/*
=============================================================================
  NORTHWIND COMMERCE - INFRASTRUCTURE SETUP
  Creates databases, warehouses, and resource monitors for the ELT platform.
=============================================================================
*/

-- ============================================================================
-- WAREHOUSES
-- ============================================================================

CREATE WAREHOUSE IF NOT EXISTS NORTHWIND_LOAD_WH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for data loading operations';

CREATE WAREHOUSE IF NOT EXISTS NORTHWIND_TRANSFORM_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 120
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for dbt and transformation workloads';

CREATE WAREHOUSE IF NOT EXISTS NORTHWIND_ANALYTICS_WH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for dashboard queries and ad-hoc analytics';

-- ============================================================================
-- RESOURCE MONITORS
-- ============================================================================

CREATE OR REPLACE RESOURCE MONITOR NORTHWIND_LOAD_MONITOR
    WITH
        CREDIT_QUOTA = 50
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
        TRIGGERS
            ON 75 PERCENT DO NOTIFY
            ON 90 PERCENT DO NOTIFY
            ON 100 PERCENT DO SUSPEND;

CREATE OR REPLACE RESOURCE MONITOR NORTHWIND_TRANSFORM_MONITOR
    WITH
        CREDIT_QUOTA = 100
        FREQUENCY = MONTHLY
        START_TIMESTAMP = IMMEDIATELY
        TRIGGERS
            ON 75 PERCENT DO NOTIFY
            ON 90 PERCENT DO NOTIFY
            ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE NORTHWIND_LOAD_WH SET RESOURCE_MONITOR = NORTHWIND_LOAD_MONITOR;
ALTER WAREHOUSE NORTHWIND_TRANSFORM_WH SET RESOURCE_MONITOR = NORTHWIND_TRANSFORM_MONITOR;

-- ============================================================================
-- DATABASES
-- ============================================================================

CREATE DATABASE IF NOT EXISTS NORTHWIND_RAW
    COMMENT = 'Landing zone for raw ingested data from source systems';

CREATE DATABASE IF NOT EXISTS NORTHWIND_STAGING
    COMMENT = 'Cleansed and typed data ready for transformation';

CREATE DATABASE IF NOT EXISTS NORTHWIND_DW
    COMMENT = 'Star schema dimensional warehouse for analytics';

CREATE DATABASE IF NOT EXISTS NORTHWIND_MONITORING
    COMMENT = 'Pipeline monitoring, data quality results, and operational metadata';

-- ============================================================================
-- SCHEMAS - RAW DATABASE
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS NORTHWIND_RAW.ECOMMERCE
    COMMENT = 'Raw ecommerce transactional data';

CREATE SCHEMA IF NOT EXISTS NORTHWIND_RAW.STAGING_AREA
    COMMENT = 'Internal stages and file formats for data loading';

-- ============================================================================
-- SCHEMAS - STAGING DATABASE
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS NORTHWIND_STAGING.ECOMMERCE
    COMMENT = 'Cleansed and validated ecommerce data';

-- ============================================================================
-- SCHEMAS - DATA WAREHOUSE
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS NORTHWIND_DW.DIMENSIONS
    COMMENT = 'Dimension tables for the star schema';

CREATE SCHEMA IF NOT EXISTS NORTHWIND_DW.FACTS
    COMMENT = 'Fact tables for the star schema';

CREATE SCHEMA IF NOT EXISTS NORTHWIND_DW.MARTS
    COMMENT = 'Business-level aggregated views and marts';

CREATE SCHEMA IF NOT EXISTS NORTHWIND_DW.ANALYTICS
    COMMENT = 'Analytics views for dashboard consumption';

-- ============================================================================
-- SCHEMAS - MONITORING DATABASE
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS NORTHWIND_MONITORING.PIPELINE
    COMMENT = 'Pipeline execution logs and metrics';

CREATE SCHEMA IF NOT EXISTS NORTHWIND_MONITORING.DATA_QUALITY
    COMMENT = 'Data quality test results and thresholds';

-- ============================================================================
-- INTERNAL STAGES
-- ============================================================================

CREATE OR REPLACE STAGE NORTHWIND_RAW.STAGING_AREA.ECOMMERCE_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Internal stage for ecommerce source files';

-- ============================================================================
-- FILE FORMATS
-- ============================================================================

CREATE OR REPLACE FILE FORMAT NORTHWIND_RAW.STAGING_AREA.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    COMMENT = 'Standard CSV format for ecommerce data files';

CREATE OR REPLACE FILE FORMAT NORTHWIND_RAW.STAGING_AREA.JSON_FORMAT
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
    COMMENT = 'JSON format for semi-structured data';

CREATE OR REPLACE FILE FORMAT NORTHWIND_RAW.STAGING_AREA.PARQUET_FORMAT
    TYPE = 'PARQUET'
    COMMENT = 'Parquet format for columnar data files';

-- ============================================================================
-- SEQUENCES
-- ============================================================================

CREATE OR REPLACE SEQUENCE NORTHWIND_DW.DIMENSIONS.SEQ_CUSTOMER_KEY START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE NORTHWIND_DW.DIMENSIONS.SEQ_PRODUCT_KEY START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE NORTHWIND_DW.DIMENSIONS.SEQ_SUPPLIER_KEY START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE NORTHWIND_DW.DIMENSIONS.SEQ_WAREHOUSE_KEY START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE NORTHWIND_DW.DIMENSIONS.SEQ_EMPLOYEE_KEY START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE NORTHWIND_DW.DIMENSIONS.SEQ_PROMOTION_KEY START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE NORTHWIND_DW.DIMENSIONS.SEQ_GEOGRAPHY_KEY START = 1 INCREMENT = 1;
