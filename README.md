# Fashion Sales Data Warehouse

A comprehensive end-to-end Data Engineering project that transforms raw fashion retail sales data into an analytics-ready Data Warehouse using a Star Schema dimensional model, automated with Apache Airflow.

---

## Project Overview

The Fashion Sales Data Warehouse is designed to centralize business logic and provide a **Single Source of Truth** for sales analytics.

### Key Objectives

- **Clean & Standardize** — Transform raw sales, customer, and product data into structured formats using Python and pandas.
- **Historical Tracking** — Implement Slowly Changing Dimensions (SCD Type 2) to track changes in customer and product information.
- **Performance Optimization** — Use a Star Schema to support high-speed analytical querying.
- **Automation** — Orchestrate the full ETL pipeline using Apache Airflow with dependency management and retry handling.

---

## System Architecture

The project follows a multi-layer storage approach to ensure data integrity and traceability.

| Layer | Name | Description |
|---|---|---|
| 1 | Source | Raw CSV flat files containing monthly fashion sales transactions |
| 2 | Staging | Temporary layer used for data cleansing and validation |
| 3 | Data Warehouse | Final analytical layer built as a Star Schema |

---

## Data Model — Star Schema

### Fact Table
- `fact_sales` — Grain: one record per order line item

### Dimension Tables

| Table | Notes |
|---|---|
| `dim_customer` | SCD Type 2 |
| `dim_product` | SCD Type 2 |
| `dim_date` | Full date hierarchy |

### SCD Type 2
Implemented for `dim_customer` and `dim_product`.
Tracked columns: `effective_from`, `effective_to`, `is_current`

---

## Tech Stack

| Component | Technology |
|---|---|
| Database | PostgreSQL |
| ETL | Python + Pandas |
| Orchestration | Apache Airflow |
| Environment | Docker / Astro CLI |
| Modeling | Star Schema / Dimensional Modeling |

---

## Airflow DAG

The pipeline consists of 7 sequential tasks:

| Task | Description |
|---|---|
| `create_dw_objects` | Creates schemas and tables if they do not exist |
| `extract_and_clean` | Reads CSV files, cleans and validates data |
| `load_staging` | Loads cleaned batch into `staging.stg_sales` |
| `load_dimensions` | Loads dimensions and applies SCD Type 2 logic |
| `load_fact` | Loads rows into `dwh.fact_sales` using surrogate keys |
| `data_quality` | Validates row counts, NULLs, and referential integrity |
| `archive_source_files` | Moves processed files to `data/archive/` |

---

## Dataset

Fashion retail sales data containing US-based transactions.

- **Format:** CSV flat files
- **Records:** 50 transactions across 3 months (Jan–Mar 2025)
- **Categories:** Women, Men, Footwear, Accessories
- **Columns:** `order_id`, `order_date`, `customer_id`, `customer_name`, `city`, `country`, `product_id`, `product_name`, `category`, `quantity`, `unit_price`, `unit_cost`

---

## Repository Structure

```
fashion-sales-etl/
│
├── dags/
│   └── retail_sales_etl.py         ← Airflow DAG (7 tasks)
│
├── data/
│   ├── sales_2025_01.csv
│   ├── sales_2025_02.csv
│   ├── sales_2025_03.csv
│   └── archive/                    ← Processed files moved here
│
├── include/
│   ├── transform_helpers.py        ← ETL logic
│   └── sql/
│       └── create_dw_tables.sql    ← DW schema creation
│
├── postgres/
│   └── init/
│       └── init_db.sql             ← Database initialization
│
├── requirements.txt
├── Dockerfile
└── README.md
```

---

## Getting Started

**1. Clone the repository**
```bash
git clone https://github.com/Safaa-Mahmoud3/fashion-sales-etl.git
cd fashion-sales-etl
```

**2. Start the environment**
```bash
astro dev start
```

**3. Open Airflow UI**
```
http://localhost:8080
```
Default login: `admin` / `admin`

**4. Add PostgreSQL Connection**

Go to Admin → Connections → Add:

| Field | Value |
|---|---|
| Conn Id | `fashion_dwh` |
| Conn Type | Postgres |
| Host | `postgres` |
| Database | `fashion_dwh` |
| Login | `postgres` |
| Password | `postgres` |
| Port | `5432` |

**5. Add source CSV files to `data/` folder**

**6. Trigger the DAG:** `fashion_sales_etl`

---

## Sample Validation Queries

```sql
-- Row counts
SELECT COUNT(*) FROM staging.stg_sales;
SELECT COUNT(*) FROM dwh.dim_customer;
SELECT COUNT(*) FROM dwh.dim_product;
SELECT COUNT(*) FROM dwh.dim_date;
SELECT COUNT(*) FROM dwh.fact_sales;

-- Sales by category
SELECT p.category,
       SUM(f.sales_amount)  AS total_sales,
       SUM(f.profit_amount) AS total_profit
FROM dwh.fact_sales f
JOIN dwh.dim_product p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;

-- SCD Type 2 history
SELECT customer_id, customer_name, city,
       effective_from, effective_to, is_current
FROM dwh.dim_customer
ORDER BY customer_id, effective_from;
```

---

## Results

- Automated a manual data processing workflow across multiple monthly CSV files
- Improved data consistency through staging layer separation and validation checks
- Enabled fast analytical queries using a structured Star Schema
- Preserved historical changes in customer and product data using SCD Type 2

---
## Power BI Dashboard

An interactive dashboard built on top of the Data Warehouse to visualize key business metrics and enable data-driven decision making.

### Dashboard Features

| Feature | Description |
|---------|-------------|
| **Sales Performance** | Track total sales, profit, and quantity trends over time |
| **Category Analysis** | Analyze sales breakdown by product category (Women, Men, Footwear, Accessories) |
| **Geographic Distribution** | Visualize sales performance across cities and countries |
| **Time Series** | Explore daily, monthly, and quarterly sales patterns |

### Technical Implementation

- **Data Source:** PostgreSQL Data Warehouse (`fashion_dwh`)
- **Connection:** DirectQuery mode for real-time insights
- **File Location:** `/dashboard/Fashion_Sales_Dashboard.pbix`
![Dashboard](https://github.com/user-attachments/assets/34402198-81dc-4326-8e38-8722ec08d2c4)

---
## Future Improvements

- Add file hash tracking to prevent duplicate loads
- Integrate dbt for transformation and modeling
- Deploy to cloud environment (AWS/GCP)
- Extend to full Medallion Architecture
