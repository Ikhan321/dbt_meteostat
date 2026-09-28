1️⃣ What business problem does your dbt model solve?

**Business Problem**
Northwind’s raw operational data is difficult to analyze because it is stored across multiple normalized tables with inconsistent naming and data types. Analysts must repeatedly write long SQL joins and manually calculate revenue, which leads to slow dashboards and inconsistent business metrics.
My dbt project solves this by cleaning the raw data, joining it into a unified sales dataset, and creating a monthly sales performance mart that provides consistent, reliable KPIs for reporting and analysis.


2️⃣ Which models did you build, and what does each do?

**Models Built**

* **Staging Layer**
  * `staging_orders`: cleans and standardizes order data
  * `staging_order_details`: cleans line-item data
  * `staging_products`: cleans product information
  * `staging_categories`: cleans category information
* **Prep Layer**
  * `prep_sales`: joins all staging tables and calculates business metrics such as revenue, order year, and order month
* **Mart Layer**
  * `mart_sales_performance`: aggregates sales by year, month, and category to produce KPIs such as total revenue, total orders, and average reve



3️⃣ What insights can your mart provide to Northwind?

The `mart_sales_performance` model enables Northwind to analyze monthly sales trends across product categories.

It provides insights such as:

* Which categories generate the most revenue
* Monthly and yearly revenue trends
* Seasonal patterns in customer purchasing
* Average revenue per order
* Total number of orders per month

These insights help the business make decisions about inventory, promotions, and product strategy.



4️⃣ What was your biggest learning moment?

**Biggest Learning Moment**

My biggest learning moment was understanding how dbt’s layered approach (staging → prep → marts) creates a clean and maintainable analytics pipeline.
I learned how important it is to standardize raw data, centralize business logic such as revenue calculations, and build aggregated marts that are fast and reliable for dashboards.
This project helped me understand how real analytics engineering teams structure their data models to ensure consistency and scalability.
