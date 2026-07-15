# Northwind Commerce: Synthetic ecommerce data generator using Faker


"""
Generates realistic ecommerce data for the Northwind Commerce data warehouse.
Produces CSV files for all entities with valid referential integrity.
"""

import csv
import os
import random
import uuid
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any

from faker import Faker
from loguru import logger

fake = Faker()
Faker.seed(42)
random.seed(42)

OUTPUT_DIR = Path(__file__).parent.parent / "data"
OUTPUT_DIR.mkdir(exist_ok=True)

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

RECORD_COUNTS = {
    "customers": 10_000,
    "products": 500,
    "categories": 30,
    "orders": 100_000,
    "order_items": 250_000,
    "payments": 50_000,
    "returns": 20_000,
    "shipments": 15_000,
    "suppliers": 200,
    "warehouses": 20,
    "inventory": 5_000,
    "employees": 100,
    "promotions": 50,
}

CUSTOMER_SEGMENTS = ["Consumer", "Corporate", "Small Business", "Enterprise"]
LOYALTY_TIERS = ["Bronze", "Silver", "Gold", "Platinum"]
ORDER_STATUSES = ["Pending", "Processing", "Shipped", "Delivered", "Cancelled"]
PAYMENT_METHODS = ["Credit Card", "Debit Card", "PayPal", "Wire Transfer", "Gift Card"]
PAYMENT_STATUSES = ["Completed", "Pending", "Failed", "Refunded"]
RETURN_REASONS = [
    "Defective", "Wrong Item", "Not as Described", "Changed Mind",
    "Too Late", "Better Price Found", "Duplicate Order"
]
RETURN_STATUSES = ["Pending", "Approved", "Rejected", "Refunded"]
SHIPMENT_STATUSES = ["Preparing", "In Transit", "Delivered", "Lost", "Returned"]
CARRIERS = ["FedEx", "UPS", "USPS", "DHL", "Amazon Logistics"]
SHIPPING_METHODS = ["Standard", "Express", "Next Day", "Economy", "Freight"]
WAREHOUSE_TYPES = ["Distribution Center", "Fulfillment Center", "Regional Hub", "Cold Storage"]
PROMOTION_TYPES = ["Percentage Off", "Fixed Amount", "Buy One Get One", "Free Shipping", "Bundle Deal"]
DEPARTMENTS = ["Sales", "Marketing", "Operations", "Logistics", "Customer Service", "IT", "Finance"]
PRODUCT_CATEGORIES = [
    ("Electronics", ["Smartphones", "Laptops", "Tablets", "Headphones", "Cameras"]),
    ("Clothing", ["Men's Apparel", "Women's Apparel", "Children's", "Footwear", "Accessories"]),
    ("Home & Garden", ["Furniture", "Kitchenware", "Bedding", "Lighting", "Garden Tools"]),
    ("Sports", ["Fitness", "Outdoor", "Team Sports", "Water Sports", "Winter Sports"]),
    ("Books", ["Fiction", "Non-Fiction", "Academic", "Children's Books", "Comics"]),
    ("Beauty", ["Skincare", "Makeup", "Haircare", "Fragrance", "Bath & Body"]),
]
BRANDS = [
    "NorthStar", "EcoVibe", "TechPulse", "UrbanEdge", "PrimeCore",
    "BlueHorizon", "SwiftLine", "GreenLeaf", "NovaWave", "SilverPeak",
    "AquaFlow", "VoltEdge", "PureForm", "ZenCraft", "IronBark"
]


def gen_id() -> str:
    return str(uuid.uuid4())[:12].replace("-", "").upper()


def write_csv(filename: str, rows: list[dict[str, Any]]) -> str:
    filepath = OUTPUT_DIR / f"{filename}.csv"
    if not rows:
        return str(filepath)
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    logger.info(f"Written {len(rows):,} rows to {filepath.name}")
    return str(filepath)


# ---------------------------------------------------------------------------
# Generators
# ---------------------------------------------------------------------------

def generate_categories() -> list[dict]:
    rows = []
    cat_id = 0
    for parent_name, subcats in PRODUCT_CATEGORIES:
        cat_id += 1
        parent_id = f"CAT-{cat_id:04d}"
        rows.append({
            "CATEGORY_ID": parent_id,
            "CATEGORY_NAME": parent_name,
            "PARENT_CATEGORY_ID": None,
            "DESCRIPTION": f"{parent_name} products and accessories",
        })
        for sub in subcats:
            cat_id += 1
            rows.append({
                "CATEGORY_ID": f"CAT-{cat_id:04d}",
                "CATEGORY_NAME": sub,
                "PARENT_CATEGORY_ID": parent_id,
                "DESCRIPTION": f"{sub} under {parent_name}",
            })
    return rows


def generate_suppliers(n: int) -> list[dict]:
    rows = []
    for _ in range(n):
        rows.append({
            "SUPPLIER_ID": f"SUP-{gen_id()}",
            "SUPPLIER_NAME": fake.company(),
            "CONTACT_NAME": fake.name(),
            "CONTACT_EMAIL": fake.company_email(),
            "PHONE": fake.phone_number(),
            "ADDRESS": fake.street_address(),
            "CITY": fake.city(),
            "STATE": fake.state_abbr(),
            "COUNTRY": "US",
            "POSTAL_CODE": fake.zipcode(),
            "PAYMENT_TERMS": random.choice(["Net 30", "Net 60", "Net 90", "COD"]),
            "LEAD_TIME_DAYS": random.randint(3, 45),
            "RATING": round(random.uniform(2.0, 5.0), 1),
            "IS_ACTIVE": random.random() > 0.05,
        })
    return rows


def generate_warehouses(n: int) -> list[dict]:
    rows = []
    for i in range(n):
        rows.append({
            "WAREHOUSE_ID": f"WH-{i+1:04d}",
            "WAREHOUSE_NAME": f"{fake.city()} {random.choice(WAREHOUSE_TYPES)}",
            "WAREHOUSE_TYPE": random.choice(WAREHOUSE_TYPES),
            "ADDRESS": fake.street_address(),
            "CITY": fake.city(),
            "STATE": fake.state_abbr(),
            "COUNTRY": "US",
            "POSTAL_CODE": fake.zipcode(),
            "CAPACITY_UNITS": random.randint(10000, 500000),
            "MANAGER_ID": None,
            "IS_ACTIVE": True,
        })
    return rows


def generate_employees(n: int, warehouse_ids: list[str]) -> list[dict]:
    rows = []
    for i in range(n):
        rows.append({
            "EMPLOYEE_ID": f"EMP-{i+1:05d}",
            "FIRST_NAME": fake.first_name(),
            "LAST_NAME": fake.last_name(),
            "EMAIL": fake.company_email(),
            "PHONE": fake.phone_number(),
            "HIRE_DATE": fake.date_between(start_date="-10y", end_date="-30d"),
            "DEPARTMENT": random.choice(DEPARTMENTS),
            "JOB_TITLE": fake.job(),
            "MANAGER_ID": f"EMP-{random.randint(1, max(1, i)):05d}" if i > 0 else None,
            "WAREHOUSE_ID": random.choice(warehouse_ids),
            "SALARY": round(random.uniform(35000, 150000), 2),
            "IS_ACTIVE": random.random() > 0.08,
        })
    return rows


def generate_products(n: int, category_ids: list[str], supplier_ids: list[str]) -> list[dict]:
    rows = []
    for _ in range(n):
        price = round(random.uniform(5.0, 2000.0), 2)
        cost = round(price * random.uniform(0.3, 0.7), 2)
        launch = fake.date_between(start_date="-5y", end_date="-30d")
        rows.append({
            "PRODUCT_ID": f"PRD-{gen_id()}",
            "PRODUCT_NAME": f"{random.choice(BRANDS)} {fake.catch_phrase()}",
            "CATEGORY_ID": random.choice(category_ids),
            "SUBCATEGORY": None,
            "BRAND": random.choice(BRANDS),
            "SUPPLIER_ID": random.choice(supplier_ids),
            "UNIT_PRICE": price,
            "UNIT_COST": cost,
            "WEIGHT_KG": round(random.uniform(0.1, 50.0), 3),
            "IS_ACTIVE": random.random() > 0.1,
            "LAUNCH_DATE": launch,
            "DISCONTINUE_DATE": launch + timedelta(days=random.randint(365, 2000)) if random.random() < 0.1 else None,
            "SKU": f"SKU-{gen_id()}",
            "DESCRIPTION": fake.sentence(nb_words=12),
        })
    return rows


def generate_customers(n: int) -> list[dict]:
    rows = []
    for _ in range(n):
        reg_date = fake.date_time_between(start_date="-5y", end_date="-1d")
        rows.append({
            "CUSTOMER_ID": f"CUS-{gen_id()}",
            "FIRST_NAME": fake.first_name(),
            "LAST_NAME": fake.last_name(),
            "EMAIL": fake.email(),
            "PHONE": fake.phone_number(),
            "DATE_OF_BIRTH": fake.date_of_birth(minimum_age=18, maximum_age=80),
            "GENDER": random.choice(["Male", "Female", "Non-Binary", "Prefer Not to Say"]),
            "ADDRESS_LINE1": fake.street_address(),
            "ADDRESS_LINE2": fake.secondary_address() if random.random() < 0.3 else None,
            "CITY": fake.city(),
            "STATE": fake.state_abbr(),
            "POSTAL_CODE": fake.zipcode(),
            "COUNTRY": "US",
            "CUSTOMER_SEGMENT": random.choice(CUSTOMER_SEGMENTS),
            "REGISTRATION_DATE": reg_date,
            "IS_ACTIVE": random.random() > 0.1,
            "LOYALTY_TIER": random.choice(LOYALTY_TIERS),
        })
    return rows


def generate_promotions(n: int) -> list[dict]:
    rows = []
    for i in range(n):
        start = fake.date_between(start_date="-2y", end_date="today")
        rows.append({
            "PROMOTION_ID": f"PROMO-{i+1:04d}",
            "PROMOTION_NAME": f"{fake.catch_phrase()} Sale",
            "PROMOTION_TYPE": random.choice(PROMOTION_TYPES),
            "DISCOUNT_PERCENT": round(random.uniform(5, 50), 2) if random.random() > 0.4 else None,
            "DISCOUNT_AMOUNT": round(random.uniform(5, 100), 2) if random.random() > 0.6 else None,
            "START_DATE": start,
            "END_DATE": start + timedelta(days=random.randint(7, 90)),
            "MIN_ORDER_VALUE": round(random.uniform(25, 200), 2) if random.random() > 0.5 else None,
            "IS_ACTIVE": random.random() > 0.3,
            "APPLICABLE_CATEGORIES": ",".join(random.sample(
                [c[0] for c in PRODUCT_CATEGORIES], k=random.randint(1, 3)
            )),
        })
    return rows


def generate_orders(
    n: int,
    customer_ids: list[str],
    warehouse_ids: list[str],
    employee_ids: list[str],
    promotion_ids: list[str],
) -> list[dict]:
    rows = []
    for _ in range(n):
        order_date = fake.date_time_between(start_date="-3y", end_date="-1d")
        status = random.choice(ORDER_STATUSES)
        shipped = order_date + timedelta(days=random.randint(1, 5)) if status in ("Shipped", "Delivered") else None
        subtotal = round(random.uniform(10, 5000), 2)
        tax = round(subtotal * random.uniform(0.05, 0.12), 2)
        discount = round(subtotal * random.uniform(0, 0.2), 2) if random.random() > 0.6 else 0
        rows.append({
            "ORDER_ID": f"ORD-{gen_id()}",
            "CUSTOMER_ID": random.choice(customer_ids),
            "ORDER_DATE": order_date,
            "REQUIRED_DATE": (order_date + timedelta(days=random.randint(5, 30))).date(),
            "SHIPPED_DATE": shipped,
            "ORDER_STATUS": status,
            "SHIPPING_METHOD": random.choice(SHIPPING_METHODS),
            "SHIPPING_COST": round(random.uniform(0, 50), 2),
            "SUBTOTAL": subtotal,
            "TAX_AMOUNT": tax,
            "DISCOUNT_AMOUNT": discount,
            "TOTAL_AMOUNT": round(subtotal + tax - discount, 2),
            "WAREHOUSE_ID": random.choice(warehouse_ids),
            "EMPLOYEE_ID": random.choice(employee_ids),
            "PROMOTION_ID": random.choice(promotion_ids) if random.random() < 0.3 else None,
            "NOTES": fake.sentence() if random.random() < 0.1 else None,
        })
    return rows


def generate_order_items(
    orders: list[dict], product_ids: list[str], avg_items_per_order: float = 2.5
) -> list[dict]:
    rows = []
    for order in orders:
        n_items = max(1, int(random.expovariate(1 / avg_items_per_order)))
        n_items = min(n_items, 10)
        for _ in range(n_items):
            qty = random.randint(1, 5)
            price = round(random.uniform(5, 500), 2)
            discount_pct = round(random.uniform(0, 25), 2) if random.random() < 0.3 else 0
            rows.append({
                "ORDER_ITEM_ID": f"OI-{gen_id()}",
                "ORDER_ID": order["ORDER_ID"],
                "PRODUCT_ID": random.choice(product_ids),
                "QUANTITY": qty,
                "UNIT_PRICE": price,
                "DISCOUNT_PERCENT": discount_pct,
                "LINE_TOTAL": round(qty * price * (1 - discount_pct / 100), 2),
            })
    return rows


def generate_payments(orders: list[dict], n: int) -> list[dict]:
    rows = []
    sampled_orders = random.sample(orders, min(n, len(orders)))
    for order in sampled_orders:
        rows.append({
            "PAYMENT_ID": f"PAY-{gen_id()}",
            "ORDER_ID": order["ORDER_ID"],
            "PAYMENT_DATE": order["ORDER_DATE"] + timedelta(minutes=random.randint(1, 60)) if isinstance(order["ORDER_DATE"], datetime) else order["ORDER_DATE"],
            "PAYMENT_METHOD": random.choice(PAYMENT_METHODS),
            "AMOUNT": order["TOTAL_AMOUNT"],
            "CURRENCY": "USD",
            "PAYMENT_STATUS": random.choice(PAYMENT_STATUSES),
            "TRANSACTION_REF": f"TXN-{gen_id()}",
        })
    return rows


def generate_returns(orders: list[dict], product_ids: list[str], n: int) -> list[dict]:
    rows = []
    delivered = [o for o in orders if o["ORDER_STATUS"] == "Delivered"]
    sampled = random.sample(delivered, min(n, len(delivered)))
    for order in sampled:
        rows.append({
            "RETURN_ID": f"RET-{gen_id()}",
            "ORDER_ID": order["ORDER_ID"],
            "PRODUCT_ID": random.choice(product_ids),
            "RETURN_DATE": order["ORDER_DATE"] + timedelta(days=random.randint(3, 45)) if isinstance(order["ORDER_DATE"], datetime) else None,
            "RETURN_REASON": random.choice(RETURN_REASONS),
            "RETURN_STATUS": random.choice(RETURN_STATUSES),
            "REFUND_AMOUNT": round(random.uniform(5, float(order["TOTAL_AMOUNT"])), 2),
            "QUANTITY_RETURNED": random.randint(1, 3),
        })
    return rows


def generate_shipments(orders: list[dict], warehouse_ids: list[str], n: int) -> list[dict]:
    rows = []
    shipped = [o for o in orders if o["ORDER_STATUS"] in ("Shipped", "Delivered")]
    sampled = random.sample(shipped, min(n, len(shipped)))
    for order in sampled:
        ship_date = order["SHIPPED_DATE"] or order["ORDER_DATE"]
        delivery = ship_date + timedelta(days=random.randint(1, 14)) if isinstance(ship_date, datetime) else None
        rows.append({
            "SHIPMENT_ID": f"SHP-{gen_id()}",
            "ORDER_ID": order["ORDER_ID"],
            "WAREHOUSE_ID": random.choice(warehouse_ids),
            "CARRIER": random.choice(CARRIERS),
            "TRACKING_NUMBER": f"{random.choice(CARRIERS)[:2].upper()}{random.randint(100000000, 999999999)}",
            "SHIP_DATE": ship_date,
            "DELIVERY_DATE": delivery,
            "SHIPMENT_STATUS": random.choice(SHIPMENT_STATUSES),
            "SHIPPING_COST": round(random.uniform(5, 100), 2),
            "WEIGHT_KG": round(random.uniform(0.5, 30), 3),
        })
    return rows


def generate_inventory(product_ids: list[str], warehouse_ids: list[str]) -> list[dict]:
    rows = []
    for prod_id in product_ids:
        n_warehouses = random.randint(1, 4)
        for wh_id in random.sample(warehouse_ids, min(n_warehouses, len(warehouse_ids))):
            on_hand = random.randint(0, 5000)
            rows.append({
                "INVENTORY_ID": f"INV-{gen_id()}",
                "PRODUCT_ID": prod_id,
                "WAREHOUSE_ID": wh_id,
                "QUANTITY_ON_HAND": on_hand,
                "QUANTITY_RESERVED": random.randint(0, min(on_hand, 200)),
                "REORDER_POINT": random.randint(10, 500),
                "REORDER_QUANTITY": random.randint(50, 2000),
                "LAST_RESTOCK_DATE": fake.date_between(start_date="-90d", end_date="today"),
                "UNIT_COST": round(random.uniform(1, 500), 2),
            })
    return rows


# ---------------------------------------------------------------------------
# Main orchestrator
# ---------------------------------------------------------------------------

def main():
    logger.info("Starting Northwind Commerce data generation...")

    # Independent entities
    categories = generate_categories()
    write_csv("categories", categories)
    category_ids = [c["CATEGORY_ID"] for c in categories]

    suppliers = generate_suppliers(RECORD_COUNTS["suppliers"])
    write_csv("suppliers", suppliers)
    supplier_ids = [s["SUPPLIER_ID"] for s in suppliers]

    warehouses = generate_warehouses(RECORD_COUNTS["warehouses"])
    write_csv("warehouses", warehouses)
    warehouse_ids = [w["WAREHOUSE_ID"] for w in warehouses]

    employees = generate_employees(RECORD_COUNTS["employees"], warehouse_ids)
    write_csv("employees", employees)
    employee_ids = [e["EMPLOYEE_ID"] for e in employees]

    # Assign managers to warehouses
    for wh in warehouses:
        wh["MANAGER_ID"] = random.choice(employee_ids)

    products = generate_products(RECORD_COUNTS["products"], category_ids, supplier_ids)
    write_csv("products", products)
    product_ids = [p["PRODUCT_ID"] for p in products]

    customers = generate_customers(RECORD_COUNTS["customers"])
    write_csv("customers", customers)
    customer_ids = [c["CUSTOMER_ID"] for c in customers]

    promotions = generate_promotions(RECORD_COUNTS["promotions"])
    write_csv("promotions", promotions)
    promotion_ids = [p["PROMOTION_ID"] for p in promotions]

    # Transactional entities
    logger.info("Generating orders (this may take a moment)...")
    orders = generate_orders(
        RECORD_COUNTS["orders"], customer_ids, warehouse_ids, employee_ids, promotion_ids
    )
    write_csv("orders", orders)

    logger.info("Generating order items...")
    order_items = generate_order_items(orders, product_ids)
    write_csv("order_items", order_items)

    payments = generate_payments(orders, RECORD_COUNTS["payments"])
    write_csv("payments", payments)

    returns = generate_returns(orders, product_ids, RECORD_COUNTS["returns"])
    write_csv("returns", returns)

    shipments = generate_shipments(orders, warehouse_ids, RECORD_COUNTS["shipments"])
    write_csv("shipments", shipments)

    inventory = generate_inventory(product_ids, warehouse_ids)
    write_csv("inventory", inventory)

    logger.info("Data generation complete!")
    logger.info(f"Files written to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
