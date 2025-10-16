# 🏬 Olist E-Commerce Data Analysis (SQL Server Project)

## 📋 Project Objective
This project analyzes real e-commerce data from the Brazilian marketplace **Olist** using SQL Server.  
The goal is to demonstrate data-engineering and analytical skills through:
- Data cleaning and integrity validation  
- Data correction and transformation  
- Business-driven analysis and insights  

The dataset was imported from the public **Olist dataset** on Kaggle and processed in **SQL Server Management Studio 20**.

---

## ⚙️ Tech Stack
| Tool | Purpose |
|------|----------|
| **SQL Server (T-SQL)** | Data import, cleaning, transformation, and analysis |
| **Kaggle – Olist Dataset** | Public e-commerce dataset |
| **GitHub** | Project version control and portfolio hosting |

---

## 🗂️ Project Structure
| File | Description |
|------|--------------|
| `01_import.sql` | Creates the database and verifies successful dataset import |
| `02_data_cleaning.sql` | Performs data profiling (nulls, duplicates, data types, integrity checks) |
| `03_data_correction.sql` | Fixes identified issues — invalid payments, missing references, inconsistent IDs |
| `04_analysis.sql` | Builds analytical views and answers business questions using SQL queries |

---

## 🧹 Data Cleaning & Correction Summary
**Key data issues found and addressed:**
- Removed invalid payments (`payment_value <= 0`)  
- Corrected `payment_installments <= 0` to 1  
- Deleted orders without payment references (maintaining data consistency)  
- Verified uniqueness of `(order_id, order_item_id)` and `(order_id, payment_sequential)`  
- Retained `NULL` values for incomplete product records (to preserve truth in data)  
- Confirmed foreign-key integrity between orders, customers, payments, and items  

---

## 💡 Business Questions Answered
1. **What is the total revenue and order count per month?**  
   → Aggregated monthly sales trend and seasonality insights.  

2. **What are the most common payment types, and how do installment patterns affect revenue?**  
   → Identified top payment methods and average installment behavior.  

3. **How long does delivery take from purchase to delivery date, and how has that changed over time?**  
   → Measured average delivery duration per month to track logistics performance.  

4. **Which states and cities generate the most orders and revenue?**  
   → Ranked top-performing regions and customer hubs across Brazil.  

5. **Which product categories contribute most to total sales?**  
   → Highlighted top revenue-generating product types.  

6. **What are Olist’s overall performance metrics?**  
   → Summarized total orders, total revenue, and average delivery time:

   ```sql
   SELECT
     COUNT(DISTINCT order_id) AS total_orders,
     SUM(payment_value) AS total_revenue,
     AVG(delivery_time_days) AS avg_delivery_days
   FROM olist;
   ```

---

## 📊 Key Results
| Metric | Result (approx.) |
|---------|------------------|
| **Total Orders** | 99,441 |
| **Total Revenue** | ≈ R$ 16 million |
| **Average Delivery Time** | ≈ 12 days |
| **Top Payment Type** | Credit card |
| **Top Product Categories** | Bed & Bath, Health & Beauty, Sports & Leisure |
| **Top States by Revenue** | São Paulo (SP), Rio de Janeiro (RJ), Minas Gerais (MG) |

*(Values approximate; derived from the cleaned dataset.)*

---

## 🧠 Skills Demonstrated
- **Data cleaning & quality control**: null checks, duplicates, invalid values  
- **Data integrity enforcement**: referential consistency across tables  
- **Transformations**: joins, aggregations, date calculations, CASE logic  
- **Analytical storytelling**: converting raw data into business-ready KPIs  
- **SQL best practices**: comments, logical structure, re-usable views  

---

## 🏁 Conclusion
This project showcases a complete SQL data workflow — from importing raw CSVs to delivering clean, insight-driven analytics.  
It reflects skills required for **junior data analyst** and **trainee data engineer** roles, including structured querying, data validation, and business insight generation.  

---

## 📫 Author
**Alanderson Guido Oliveira**  
*Trainee Data Engineer | Data Analyst*  
[LinkedIn](https://www.linkedin.com/in/alandersong) · [GitHub](https://github.com/Alandersong)

---

## ⚖️ License

This project is shared under the [MIT License](LICENSE).  

Feel free to use it for learning, portfolio inspiration, or analytics demonstrations.