# Olist Brazil E-commerce: Where Late Deliveries Cost Reviews

### Project Overview
This project analyzes 98k+ e-commerce orders (R$13.5M in product sales) from the public Olist dataset to determine which states and sellers have systemic delivery problems, and how much those delays impact customer satisfaction and revenue.

### Key Findings (Sep 2016 – Aug 2018)
* **The Late Penalty:** 6.8% of delivered orders arrived after the promised date. Late orders average a **2.27★** rating versus **4.29★** for on-time orders. 
* **The Bottom Line:** 54% of late orders result in a 1-star review (compared to only 6.6% for on-time orders), severely damaging seller reputation.
* **Regional Bottlenecks:** Late rates are highest in AL (21%), MA (17%), SE (15%), and PI (14%).
* **Retention Reality:** Only ~3% of customers in this dataset ever reorder, indicating that repeat purchase is not a viable growth lever without first solving fulfillment logistics.

### Technical Stack & Pipeline
1. **PostgreSQL 15+:** Used for ETL, data sanitization, handling duplicates, and deriving fulfillment flags.
2. **Power BI:** Used for the final visualization layer (see `.pbix` file).

### Data Quality & Assumptions Handled in SQL
* **Cancellations:** Rather than hard-deleting canceled orders (which orphans their payment and review records), they are retained and flagged via `is_canceled`.
* **Revenue Definition:** "Net Sales" strictly sums the `price` column, excluding freight and installment interest to avoid reconciliation mismatches.
* **Geolocations:** Explicitly aggregated by zip code to prevent many-to-one fan-out issues in the data model.