-- Employee dimension

{{
    config(
        materialized='table',
        schema='DIMENSIONS'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['EMPLOYEE_ID']) }} AS EMPLOYEE_SK,
    EMPLOYEE_ID,
    FIRST_NAME,
    LAST_NAME,
    FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME,
    EMAIL,
    DEPARTMENT,
    JOB_TITLE,
    HIRE_DATE,
    MANAGER_ID,
    WAREHOUSE_ID
FROM {{ source('staging', 'STG_EMPLOYEES') }}
