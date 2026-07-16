# 🚀 Modern ELT Data Warehouse on Snowflake

> **An end-to-end production-style data engineering project demonstrating modern ELT architecture using Snowflake, Python, dbt, Snowpark, and Streamlit.**

![Snowflake](https://img.shields.io/badge/Snowflake-Data%20Cloud-29B5E8?logo=snowflake\&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)
![dbt](https://img.shields.io/badge/dbt-Core-orange?logo=dbt)
![Streamlit](https://img.shields.io/badge/Streamlit-App-red?logo=streamlit)
![License](https://img.shields.io/badge/License-MIT-green)

---

# 📖 Overview

Modern data platforms require more than loading CSV files into a database—they require scalable, automated, and observable data pipelines.

This project simulates a real-world e-commerce company and demonstrates how to build a modern ELT data warehouse entirely on **Snowflake**. It covers the complete lifecycle of data engineering, including ingestion, transformation, orchestration, dimensional modeling, monitoring, and visualization.

The project is designed to mirror production data engineering practices and showcase technologies commonly used in enterprise environments.

---

# 🏗️ Architecture

```
                    Fake Ecommerce Data
                           │
                 Python Data Generator
                           │
                 Snowflake Internal Stage
                           │
                     Snowpipe Ingestion
                           │
                      RAW Data Layer
                           │
                   Streams & Tasks
                           │
                    STAGING Layer
                           │
                      dbt Transformations
                           │
                     Star Schema (MART)
                           │
                Analytics Views & Metrics
                           │
                  Streamlit Dashboard
```

---

# 🎯 Project Goals

* Build a production-style ELT pipeline
* Demonstrate advanced Snowflake engineering
* Implement automated incremental loading
* Design a Kimball Star Schema
* Build reusable dbt models
* Showcase Snowpark Python transformations
* Implement automated data quality testing
* Monitor pipeline performance
* Create an executive analytics dashboard

---

# 🛠️ Technology Stack

| Category             | Technology      |
| -------------------- | --------------- |
| Cloud Data Warehouse | Snowflake       |
| Programming          | Python          |
| SQL                  | Snowflake SQL   |
| DataFrames           | Snowpark Python |
| Transformation       | dbt Core        |
| Dashboard            | Streamlit       |
| Visualization        | Plotly          |
| Data Generation      | Faker           |
| Data Processing      | Pandas          |
| Version Control      | Git             |
| CI/CD                | GitHub Actions  |

---

# 📂 Repository Structure

```
snowflake-modern-elt/

├── architecture/
│   ├── architecture.png
│   
│   
│
├── data/
│
├── dbt/
│   ├── models/
│   ├── snapshots/
│   ├── tests/
│   ├── macros/
│   └── seeds/
│
├── docs/
│
├── python/
│   ├── generate_data.py
│   
│   
│   
│
├── sql/
│   ├── setup/
│   ├── raw/
│   ├── staging/
│   ├── streams/
│   ├── tasks/
│   ├── security/
│   ├── procedures/
│   └── views/
│
├── streamlit/
│   ├── streamlit.py
│   
│
├── screenshots/
│
├── README.md
├── requirements.txt
├── LICENSE
└── .gitignore
```

---

# 📊 Simulated Business

The project models **Northwind Commerce**, a fictional online retailer selling products across the United States.

The warehouse supports analytics for:

* Executive Leadership
* Sales
* Operations
* Finance
* Supply Chain
* Customer Success

---

# 📦 Data Sources

The pipeline generates realistic synthetic data using Python and Faker.

| Dataset    | Approximate Records |
| ---------- | ------------------: |
| Customers  |             100,000 |
| Products   |               1,000 |
| Orders     |           1,000,000 |
| Payments   |             250,000 |
| Returns    |             100,000 |
| Shipments  |              50,000 |
| Suppliers  |                 500 |
| Warehouses |                  20 |
| Inventory  |             250,000 |
| Employees  |                 500 |

---

# ⭐ Snowflake Features Demonstrated

* Snowflake Warehouses
* Databases & Schemas
* Internal Stages
* Named File Formats
* COPY INTO
* Snowpipe
* Streams
* Tasks
* MERGE Statements
* Dynamic Tables
* Views
* Materialized Views
* Snowpark Python
* Stored Procedures
* User Defined Functions (UDFs)
* Time Travel
* Zero Copy Cloning
* Search Optimization
* Resource Monitors
* Query History
* Access History
* Row Access Policies
* Dynamic Masking Policies
* Role-Based Access Control (RBAC)

---

# 🧩 Data Model

The warehouse follows a **Kimball Star Schema**.

## Dimension Tables

* Dim Customer
* Dim Product
* Dim Date
* Dim Warehouse
* Dim Supplier
* Dim Geography
* Dim Employee
* Dim Promotion

## Fact Tables

* Fact Orders
* Fact Payments
* Fact Inventory
* Fact Shipments
* Fact Returns

The project also implements:

* Slowly Changing Dimensions (Type 2)
* Surrogate Keys
* Incremental Loads
* Historical Tracking

---

# 🔄 ELT Pipeline

### 1. Data Generation

Python generates realistic synthetic datasets.

↓

### 2. Landing Zone

Files are uploaded into Snowflake Internal Stages.

↓

### 3. Raw Layer

Snowpipe loads data into RAW tables.

↓

### 4. Incremental Processing

Streams detect changes.

Tasks automate processing.

↓

### 5. Transformations

dbt builds staging, intermediate, and mart models.

↓

### 6. Analytics

Business-ready tables power dashboards and reporting.

---

# 📈 Dashboard

The Streamlit application includes:

### Executive Dashboard

* Revenue
* Orders
* Profit
* Average Order Value
* Monthly Trends

### Customer Analytics

* Customer Lifetime Value
* Retention
* Geographic Distribution
* Repeat Purchases

### Product Analytics

* Top Products
* Category Performance
* Sales Trends

### Inventory

* Stock Levels
* Inventory Turnover
* Warehouse Utilization

### Shipping

* Delivery Times
* Carrier Performance

### Returns

* Return Rates
* Return Reasons
* Product Quality Metrics

### Data Quality

* Duplicate Detection
* Missing Values
* Constraint Violations
* Data Freshness

### Pipeline Monitoring

* Snowpipe Status
* Task History
* Stream Activity
* Pipeline Runtime
* Processing Metrics

---

# 📊 Business KPIs

The warehouse calculates:

* Total Revenue
* Gross Profit
* Net Profit
* Customer Lifetime Value
* Average Order Value
* Repeat Customer Rate
* Inventory Turnover
* Return Rate
* Average Shipping Time
* Supplier Performance
* Warehouse Utilization
* Monthly Growth
* Year-over-Year Growth
* Category Performance

---

# 🚦 Data Quality

Automated validation includes:

* Duplicate Detection
* Missing Primary Keys
* Foreign Key Validation
* Future Date Checks
* Invalid Email Detection
* Negative Values
* Null Validation
* Row Count Validation
* Schema Drift Detection

All quality metrics are logged to monitoring tables.

---

# 🔒 Security

The project demonstrates enterprise security practices including:

* Role-Based Access Control (RBAC)
* Least Privilege Access
* Dynamic Data Masking
* Row Access Policies
* Secure Views
* Object Tagging
* Audit Logging

---

# 📸 Screenshots

The completed project will include screenshots of:

* Snowflake Architecture
* Entity Relationship Diagram
* Snowflake Worksheets
* Streamlit Dashboard
* dbt Documentation
* Pipeline Monitoring
* Warehouse Usage
* Query History

---

# 🚀 Getting Started

## Clone the Repository

```bash
git clone https://github.com/yourusername/snowflake-modern-elt.git

cd snowflake-modern-elt
```

## Install Dependencies

```bash
pip install -r requirements.txt
```

## Configure Environment

Create a `.env` file containing your Snowflake credentials.

```text
SNOWFLAKE_ACCOUNT=
SNOWFLAKE_USER=
SNOWFLAKE_PASSWORD=
SNOWFLAKE_WAREHOUSE=
SNOWFLAKE_DATABASE=
SNOWFLAKE_SCHEMA=
```

## Generate Sample Data

```bash
python python/generate_data.py
```

## Create Snowflake Objects

Execute the SQL scripts located in:

```
sql/setup/
```

## Load Raw Data

```bash
python python/upload_to_stage.py
```

## Build dbt Models

```bash
dbt run
dbt test
```

## Launch Streamlit

```bash
streamlit run streamlit/app.py
```

---

# 📚 Skills Demonstrated

* Data Engineering
* ELT Pipeline Design
* Data Warehouse Architecture
* Snowflake Administration
* Dimensional Modeling
* SQL Development
* Snowpark Python
* dbt Development
* Data Quality Engineering
* Incremental Processing
* Data Governance
* Pipeline Monitoring
* Business Intelligence

---

# 🛣️ Future Enhancements

* Snowflake Cortex AI integration
* Dynamic Tables
* Snowflake Notebooks
* Semantic Views
* Automated Alerting
* Real-Time Streaming Ingestion
* Predictive Analytics
* Machine Learning Feature Store

---

# 💼 Resume Highlights

* Designed and implemented a production-style ELT data warehouse using Snowflake, Python, dbt, and Streamlit.
* Built automated incremental pipelines using Snowflake Streams, Tasks, and Snowpipe.
* Developed a Kimball Star Schema supporting executive reporting across multiple business domains.
* Implemented automated data quality monitoring and pipeline observability.
* Created an interactive analytics application for business users using Streamlit and Plotly.

---

# 📄 License

This project is licensed under the MIT License.

---

## ⭐ If you found this project helpful, consider giving it a star!
