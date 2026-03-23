--CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dwh;

-- STAGING TABLE
CREATE TABLE IF NOT EXISTS staging.stg_sales (
    row_num        SERIAL,
    source_file    VARCHAR(100),
    batch_id       VARCHAR(30),
    order_id       VARCHAR(20),
    order_date     VARCHAR(20),
    customer_id    VARCHAR(20),
    customer_name  VARCHAR(100),
    city           VARCHAR(50),
    country        VARCHAR(50),
    product_id     VARCHAR(20),
    product_name   VARCHAR(100),
    category       VARCHAR(50),
    quantity       INTEGER,
    unit_price     NUMERIC(10,2),
    unit_cost      NUMERIC(10,2),
    sales_amount   NUMERIC(12,2),
    total_cost     NUMERIC(12,2),
    profit_amount  NUMERIC(12,2),
    loaded_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--  DIM_DATE
CREATE TABLE IF NOT EXISTS dwh.dim_date (
    date_key    INTEGER PRIMARY KEY,
    full_date   DATE        NOT NULL,
    day_num     SMALLINT    NOT NULL,
    month_num   SMALLINT    NOT NULL,
    month_name  VARCHAR(15) NOT NULL,
    quarter_num SMALLINT    NOT NULL,
    year_num    SMALLINT    NOT NULL,
    week_num    SMALLINT    NOT NULL,
    is_weekend  BOOLEAN     NOT NULL
);

-- DIM_CUSTOMER (SCD Type 2)
CREATE TABLE IF NOT EXISTS dwh.dim_customer (
    customer_key    SERIAL PRIMARY KEY,
    customer_id     VARCHAR(20)  NOT NULL,
    customer_name   VARCHAR(100) NOT NULL,
    city            VARCHAR(50),
    country         VARCHAR(50),
    effective_from  DATE         NOT NULL,
    effective_to    DATE,
    is_current      BOOLEAN      NOT NULL DEFAULT TRUE
);

-- DIM_PRODUCT (SCD Type 2)
CREATE TABLE IF NOT EXISTS dwh.dim_product (
    product_key     SERIAL PRIMARY KEY,
    product_id      VARCHAR(20)  NOT NULL,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50),
    effective_from  DATE         NOT NULL,
    effective_to    DATE,
    is_current      BOOLEAN      NOT NULL DEFAULT TRUE
);

--  FACT_SALES
CREATE TABLE IF NOT EXISTS dwh.fact_sales (
    sales_key       SERIAL PRIMARY KEY,
    order_id        VARCHAR(20)    NOT NULL,
    date_key        INTEGER        NOT NULL REFERENCES dwh.dim_date(date_key),
    customer_key    INTEGER        NOT NULL REFERENCES dwh.dim_customer(customer_key),
    product_key     INTEGER        NOT NULL REFERENCES dwh.dim_product(product_key),
    quantity        INTEGER        NOT NULL,
    unit_price      NUMERIC(10,2)  NOT NULL,
    unit_cost       NUMERIC(10,2)  NOT NULL,
    sales_amount    NUMERIC(12,2)  NOT NULL,
    total_cost      NUMERIC(12,2)  NOT NULL,
    profit_amount   NUMERIC(12,2)  NOT NULL,
    batch_id        VARCHAR(30),
    UNIQUE(order_id)
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_fact_date     ON dwh.fact_sales(date_key);
CREATE INDEX IF NOT EXISTS idx_fact_customer ON dwh.fact_sales(customer_key);
CREATE INDEX IF NOT EXISTS idx_fact_product  ON dwh.fact_sales(product_key);
CREATE INDEX IF NOT EXISTS idx_cust_id       ON dwh.dim_customer(customer_id);
CREATE INDEX IF NOT EXISTS idx_prod_id       ON dwh.dim_product(product_id);
