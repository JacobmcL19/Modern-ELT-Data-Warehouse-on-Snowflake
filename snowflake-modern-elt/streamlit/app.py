# Northwind Commerce Streamlit Dashboard - Executive Analytics
import streamlit as st
import altair as alt
from snowflake.snowpark.context import get_active_session
import pandas as pd

st.set_page_config(page_title="Northwind Commerce", layout="wide")

session = get_active_session()

COLOR_SCALE = alt.Scale(scheme="tableau10")


def run_query(sql):
    return session.sql(sql).to_pandas()


# Sidebar
st.sidebar.title("Northwind Commerce")
page = st.sidebar.radio("Navigation", [
    "Executive Dashboard",
    "Sales Analytics",
    "Customer Analytics",
    "Product Analytics",
    "Inventory",
    "Returns",
    "Shipping",
    "Data Quality",
    "Pipeline Monitoring",
])

if page == "Executive Dashboard":
    st.title("Executive Dashboard")
    kpi = run_query("""
        SELECT
            COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDERS,
            COUNT(DISTINCT CUSTOMER_ID) AS TOTAL_CUSTOMERS,
            SUM(TOTAL_AMOUNT) AS TOTAL_REVENUE,
            AVG(TOTAL_AMOUNT) AS AVG_ORDER_VALUE
        FROM NORTHWIND_DW.FACTS.FACT_ORDERS
    """)
    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Total Orders", f"{kpi['TOTAL_ORDERS'][0]:,.0f}")
    c2.metric("Customers", f"{kpi['TOTAL_CUSTOMERS'][0]:,.0f}")
    c3.metric("Revenue", f"${kpi['TOTAL_REVENUE'][0]:,.0f}")
    c4.metric("Avg Order", f"${kpi['AVG_ORDER_VALUE'][0]:,.2f}")

    monthly = run_query("SELECT * FROM NORTHWIND_DW.ANALYTICS.V_EXECUTIVE_SUMMARY ORDER BY YEAR_MONTH")

    chart_rev = alt.Chart(monthly).mark_line(point=True).encode(
        x=alt.X("YEAR_MONTH:N", title="Month"),
        y=alt.Y("TOTAL_REVENUE:Q", title="Revenue ($)"),
        tooltip=["YEAR_MONTH", "TOTAL_REVENUE"]
    ).properties(title="Monthly Revenue Trend", height=350)
    st.altair_chart(chart_rev, use_container_width=True)

    col1, col2 = st.columns(2)
    with col1:
        chart_orders = alt.Chart(monthly).mark_bar().encode(
            x=alt.X("YEAR_MONTH:N", title="Month"),
            y=alt.Y("TOTAL_ORDERS:Q", title="Orders"),
            tooltip=["YEAR_MONTH", "TOTAL_ORDERS"]
        ).properties(title="Monthly Orders", height=300)
        st.altair_chart(chart_orders, use_container_width=True)
    with col2:
        chart_aov = alt.Chart(monthly).mark_line(point=True, color="orange").encode(
            x=alt.X("YEAR_MONTH:N", title="Month"),
            y=alt.Y("AVG_ORDER_VALUE:Q", title="Avg Order Value ($)"),
            tooltip=["YEAR_MONTH", "AVG_ORDER_VALUE"]
        ).properties(title="Avg Order Value Trend", height=300)
        st.altair_chart(chart_aov, use_container_width=True)

elif page == "Sales Analytics":
    st.title("Sales Analytics")
    time_grain = st.selectbox("Time Grain", ["Monthly", "Quarterly"])

    if time_grain == "Monthly":
        sales = run_query("""
            SELECT d.YEAR_MONTH AS PERIOD, SUM(f.TOTAL_AMOUNT) AS REVENUE, COUNT(*) AS ORDERS
            FROM NORTHWIND_DW.FACTS.FACT_ORDERS f
            JOIN NORTHWIND_DW.DIMENSIONS.DIM_DATE d ON f.ORDER_DATE_KEY = d.DATE_KEY
            GROUP BY d.YEAR_MONTH ORDER BY d.YEAR_MONTH
        """)
    else:
        sales = run_query("""
            SELECT d.YEAR_QUARTER AS PERIOD, SUM(f.TOTAL_AMOUNT) AS REVENUE, COUNT(*) AS ORDERS
            FROM NORTHWIND_DW.FACTS.FACT_ORDERS f
            JOIN NORTHWIND_DW.DIMENSIONS.DIM_DATE d ON f.ORDER_DATE_KEY = d.DATE_KEY
            GROUP BY d.YEAR_QUARTER ORDER BY d.YEAR_QUARTER
        """)

    chart = alt.Chart(sales).mark_bar().encode(
        x=alt.X("PERIOD:N", title="Period"),
        y=alt.Y("REVENUE:Q", title="Revenue ($)"),
        tooltip=["PERIOD", "REVENUE", "ORDERS"]
    ).properties(title=f"{time_grain} Revenue", height=350)
    st.altair_chart(chart, use_container_width=True)

    status = run_query("""
        SELECT ORDER_STATUS, COUNT(*) AS CNT, SUM(TOTAL_AMOUNT) AS REVENUE
        FROM NORTHWIND_DW.FACTS.FACT_ORDERS GROUP BY ORDER_STATUS
    """)
    pie = alt.Chart(status).mark_arc().encode(
        theta=alt.Theta("CNT:Q"),
        color=alt.Color("ORDER_STATUS:N", scale=COLOR_SCALE),
        tooltip=["ORDER_STATUS", "CNT", "REVENUE"]
    ).properties(title="Orders by Status", height=350)
    st.altair_chart(pie, use_container_width=True)

elif page == "Customer Analytics":
    st.title("Customer Analytics")
    segment_filter = st.multiselect("Customer Segment", ["Premium", "Standard", "Budget", "Enterprise"],
                                     default=["Premium", "Standard", "Budget", "Enterprise"])
    segments_str = "', '".join(segment_filter)

    seg = run_query(f"""
        SELECT CUSTOMER_SEGMENT, COUNT(*) AS CUSTOMERS,
               SUM(LIFETIME_VALUE) AS TOTAL_LTV, AVG(LIFETIME_VALUE) AS AVG_LTV
        FROM NORTHWIND_DW.ANALYTICS.V_CUSTOMER_ANALYTICS
        WHERE CUSTOMER_SEGMENT IN ('{segments_str}')
        GROUP BY CUSTOMER_SEGMENT
    """)
    chart = alt.Chart(seg).mark_bar().encode(
        x=alt.X("CUSTOMER_SEGMENT:N", title="Segment"),
        y=alt.Y("AVG_LTV:Q", title="Avg Lifetime Value ($)"),
        color=alt.Color("CUSTOMER_SEGMENT:N", scale=COLOR_SCALE),
        tooltip=["CUSTOMER_SEGMENT", "CUSTOMERS", "AVG_LTV"]
    ).properties(title="Avg Lifetime Value by Segment", height=350)
    st.altair_chart(chart, use_container_width=True)

    top_customers = run_query("""
        SELECT FULL_NAME, LIFETIME_VALUE, TOTAL_ORDERS, LOYALTY_TIER
        FROM NORTHWIND_DW.ANALYTICS.V_CUSTOMER_ANALYTICS
        ORDER BY LIFETIME_VALUE DESC LIMIT 20
    """)
    st.subheader("Top 20 Customers by Lifetime Value")
    st.dataframe(top_customers, use_container_width=True)

elif page == "Product Analytics":
    st.title("Product Analytics")
    products = run_query("SELECT * FROM NORTHWIND_DW.ANALYTICS.V_PRODUCT_PERFORMANCE ORDER BY TOTAL_REVENUE DESC")

    col1, col2 = st.columns(2)
    with col1:
        top10 = products.head(10)
        chart = alt.Chart(top10).mark_bar().encode(
            x=alt.X("TOTAL_REVENUE:Q", title="Revenue ($)"),
            y=alt.Y("PRODUCT_NAME:N", sort="-x", title="Product"),
            tooltip=["PRODUCT_NAME", "TOTAL_REVENUE", "TOTAL_UNITS_SOLD"]
        ).properties(title="Top 10 Products by Revenue", height=350)
        st.altair_chart(chart, use_container_width=True)
    with col2:
        cat_rev = products.groupby("CATEGORY_NAME")["TOTAL_REVENUE"].sum().reset_index()
        pie = alt.Chart(cat_rev).mark_arc().encode(
            theta=alt.Theta("TOTAL_REVENUE:Q"),
            color=alt.Color("CATEGORY_NAME:N", scale=COLOR_SCALE),
            tooltip=["CATEGORY_NAME", "TOTAL_REVENUE"]
        ).properties(title="Revenue by Category", height=350)
        st.altair_chart(pie, use_container_width=True)

elif page == "Inventory":
    st.title("Inventory Management")
    inv = run_query("SELECT * FROM NORTHWIND_DW.ANALYTICS.V_INVENTORY_STATUS")

    reorder_needed = inv[inv["NEEDS_REORDER"] == True]
    st.metric("Items Needing Reorder", len(reorder_needed))

    wh_stock = inv.groupby("WAREHOUSE_NAME")["QUANTITY_ON_HAND"].sum().reset_index()
    chart = alt.Chart(wh_stock).mark_bar().encode(
        x=alt.X("WAREHOUSE_NAME:N", title="Warehouse"),
        y=alt.Y("QUANTITY_ON_HAND:Q", title="Total Stock"),
        tooltip=["WAREHOUSE_NAME", "QUANTITY_ON_HAND"]
    ).properties(title="Stock by Warehouse", height=350)
    st.altair_chart(chart, use_container_width=True)

    if len(reorder_needed) > 0:
        st.subheader("Reorder Alerts")
        st.dataframe(reorder_needed[["WAREHOUSE_NAME", "PRODUCT_NAME", "QUANTITY_ON_HAND", "REORDER_POINT"]],
                     use_container_width=True)

elif page == "Returns":
    st.title("Return Analysis")
    returns = run_query("SELECT * FROM NORTHWIND_DW.ANALYTICS.V_RETURN_ANALYSIS")
    chart = alt.Chart(returns).mark_bar().encode(
        x=alt.X("REASON:N", title="Return Reason"),
        y=alt.Y("RETURN_COUNT:Q", title="Count"),
        color=alt.Color("RETURN_STATUS:N", scale=COLOR_SCALE),
        tooltip=["REASON", "RETURN_STATUS", "RETURN_COUNT", "TOTAL_REFUNDS"]
    ).properties(title="Returns by Reason", height=350)
    st.altair_chart(chart, use_container_width=True)

    pie = alt.Chart(returns).mark_arc().encode(
        theta=alt.Theta("TOTAL_REFUNDS:Q"),
        color=alt.Color("REASON:N", scale=COLOR_SCALE),
        tooltip=["REASON", "TOTAL_REFUNDS"]
    ).properties(title="Refund Amount by Reason", height=350)
    st.altair_chart(pie, use_container_width=True)

elif page == "Shipping":
    st.title("Shipping Performance")
    shipping = run_query("SELECT * FROM NORTHWIND_DW.ANALYTICS.V_SHIPPING_PERFORMANCE")
    chart = alt.Chart(shipping).mark_bar().encode(
        x=alt.X("CARRIER:N", title="Carrier"),
        y=alt.Y("AVG_TRANSIT_DAYS:Q", title="Avg Transit Days"),
        color=alt.Color("SHIPMENT_STATUS:N", scale=COLOR_SCALE),
        xOffset="SHIPMENT_STATUS:N",
        tooltip=["CARRIER", "SHIPMENT_STATUS", "AVG_TRANSIT_DAYS", "SHIPMENT_COUNT"]
    ).properties(title="Avg Transit Days by Carrier", height=350)
    st.altair_chart(chart, use_container_width=True)

elif page == "Data Quality":
    st.title("Data Quality Monitor")
    dq = run_query("SELECT * FROM NORTHWIND_MONITORING.PUBLIC.DQ_TEST_RESULTS ORDER BY EXECUTED_AT DESC")
    passed = len(dq[dq["STATUS"] == "PASSED"])
    failed = len(dq[dq["STATUS"] == "FAILED"])

    c1, c2, c3 = st.columns(3)
    c1.metric("Total Tests", len(dq))
    c2.metric("Passed", passed)
    c3.metric("Failed", failed)

    chart = alt.Chart(dq).mark_bar().encode(
        x=alt.X("TEST_NAME:N", title="Test"),
        y=alt.Y("RECORDS_FAILED:Q", title="Records Failed"),
        color=alt.Color("STATUS:N", scale=alt.Scale(domain=["PASSED", "FAILED"], range=["#2ca02c", "#d62728"])),
        tooltip=["TEST_NAME", "TEST_CATEGORY", "RECORDS_TESTED", "RECORDS_FAILED", "STATUS"]
    ).properties(title="Test Results", height=300)
    st.altair_chart(chart, use_container_width=True)
    st.dataframe(dq[["TEST_NAME", "TEST_CATEGORY", "TABLE_NAME", "RECORDS_TESTED", "RECORDS_FAILED", "STATUS"]],
                 use_container_width=True)

elif page == "Pipeline Monitoring":
    st.title("Pipeline Monitoring")
    logs = run_query("SELECT * FROM NORTHWIND_MONITORING.PUBLIC.PIPELINE_LOG ORDER BY EXECUTED_AT DESC LIMIT 50")
    if len(logs) > 0:
        st.dataframe(logs, use_container_width=True)
    else:
        st.info("No pipeline runs logged yet. Logs will appear after task executions.")

    st.subheader("Task Execution History")
    task_history = run_query("""
        SELECT NAME, STATE, SCHEDULED_TIME, COMPLETED_TIME,
               DATEDIFF(SECOND, SCHEDULED_TIME, COMPLETED_TIME) AS DURATION_SEC
        FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
            SCHEDULED_TIME_RANGE_START => DATEADD(HOUR, -24, CURRENT_TIMESTAMP()),
            RESULT_LIMIT => 50
        ))
        ORDER BY SCHEDULED_TIME DESC
    """)
    if len(task_history) > 0:
        st.dataframe(task_history, use_container_width=True)
    else:
        st.info("No task executions in the last 24 hours.")
