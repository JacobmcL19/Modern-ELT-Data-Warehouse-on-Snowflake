-- Northwind Commerce: CDC streams on raw tables for incremental processing


/*
=============================================================================
  STREAMS - Change Data Capture
  Captures inserts/updates on raw tables to drive incremental staging loads.
=============================================================================
*/

USE DATABASE NORTHWIND_RAW;
USE SCHEMA ECOMMERCE;

CREATE OR REPLACE STREAM STM_RAW_CUSTOMERS ON TABLE RAW_CUSTOMERS
    APPEND_ONLY = FALSE
    COMMENT = 'CDC stream on raw customers for incremental staging';

CREATE OR REPLACE STREAM STM_RAW_PRODUCTS ON TABLE RAW_PRODUCTS
    APPEND_ONLY = FALSE
    COMMENT = 'CDC stream on raw products for incremental staging';

CREATE OR REPLACE STREAM STM_RAW_ORDERS ON TABLE RAW_ORDERS
    APPEND_ONLY = FALSE
    COMMENT = 'CDC stream on raw orders for incremental staging';

CREATE OR REPLACE STREAM STM_RAW_ORDER_ITEMS ON TABLE RAW_ORDER_ITEMS
    APPEND_ONLY = FALSE
    COMMENT = 'CDC stream on raw order items';

CREATE OR REPLACE STREAM STM_RAW_PAYMENTS ON TABLE RAW_PAYMENTS
    APPEND_ONLY = FALSE
    COMMENT = 'CDC stream on raw payments';

CREATE OR REPLACE STREAM STM_RAW_RETURNS ON TABLE RAW_RETURNS
    APPEND_ONLY = FALSE
    COMMENT = 'CDC stream on raw returns';

CREATE OR REPLACE STREAM STM_RAW_SHIPMENTS ON TABLE RAW_SHIPMENTS
    APPEND_ONLY = FALSE
    COMMENT = 'CDC stream on raw shipments';

CREATE OR REPLACE STREAM STM_RAW_INVENTORY ON TABLE RAW_INVENTORY
    APPEND_ONLY = FALSE
    COMMENT = 'CDC stream on raw inventory';
