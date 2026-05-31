# Case Study: Customer Loyalty & Behavioral Analytics (Danny's Diner)

## 📌 Project Overview
This project tackles a retail data analytics scenario designed to evaluate customer purchasing patterns, spending behavior, and the financial impact of a newly launched customer loyalty program. 

Using a relational database schema, I wrote advanced, optimized queries to extract actionable business insights from transaction histories to help the business scale its operations.

## 🛠️ Tech Stack & SQL Concepts Used
* **Database Engine:** Microsoft SQL Server (SSMS)
* **Advanced Querying Techniques:**
  * Common Table Expressions (CTEs)
  * Window Functions (`DENSE_RANK()`, `PARTITION BY`)
  * Data Warehousing / Denormalization Architecture
  * Conditional Logic (`CASE WHEN`)
  * Date/Time Manipulation (`DATEADD`, `BETWEEN`)
  * Multi-table Relational Joins (`LEFT JOIN`, `INNER JOIN`)

## 📊 Business Metrics Solved
1. **Customer Spend & Volume:** Aggregated total spending metrics and frequency of unique restaurant visits per customer.
2. **Product Popularity Segments:** Isolated top revenue-driving menu items globally and mapped out individual customer preferences using matrix partitioning.
3. **Loyalty Program Impact Analysis:** 
   * Segmented customer transactions happening strictly *before* and *after* their loyalty registration milestones.
   * Modeled a multi-tiered loyalty points framework, including a 1-week promotional 2x points window capped at calendar boundaries.
4. **Data Mart Reporting View:** Flattened the normalized operational tables into a single unified reporting master view for non-technical business stakeholders.

## 📂 Repository Structure
* `solution.sql`: Contains the complete database schema creation script, mock data ingestion, and fully commented solutions for all 10 business scenario questions.

---
*Maintained by Subhankar as part of a technical data analytics portfolio.*
