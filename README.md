# Olist Revenue & Delivery Performance Analysis

**Dashboard:** https://public.tableau.com/app/profile/inti.charan.kumar/viz/OlistRevenueandDeliveryPerformance/OlistE-commerceRevenueDeliveryPerformance

## Business problem
Where is revenue growing or slowing, and does delivery performance affect customer satisfaction?

## Dataset
Brazilian E-Commerce Public Dataset by Olist (Kaggle): 9 related tables, ~100k orders. Analysis window: Jan 2017 – Aug 2018 (earlier months have too few orders to trust).

## Cleaning rules
- Revenue counts delivered orders only (96,478 of 99,441 orders).
- 775 orders with no items excluded from revenue.
- 8 delivered orders without a delivery date excluded from delay analysis.
- Multiple reviews per order reduced to the latest using ROW_NUMBER().
- Delay analysis covers 95,560 of 96,203 delivered orders; 643 without a review were excluded.

## Findings
1. Revenue grew from R$111,798 (Jan 2017) to R$977,545 (May 2018) through order volume (750 → 6,749/month); average order value stayed R$124–149. Black Friday 2017 (24 Nov) brought 1,147 orders, R$149,917.
2. Only 8.0% of orders were late, but orders 8+ days late averaged 1.73 stars vs 4.29 on time (78.4% vs 9.2% gave 1–2 stars). Ratings drop sharply after 3 days late.
3. SP is 38.4% of revenue. RJ, #2 (13.3%), has a 13.5% late rate vs 8.0% average. This is association, not proof of cause.

## Recommendations (proposals, not measured results)
1. Prioritize delivery performance in RJ, then BA.
2. Alert on orders running 3+ days late.
3. Test more realistic delivery estimates in MA, CE and BA.

## Limits
Revenue is item price only. The dataset cannot show repeat purchases or retention.

## Files
`sql/` queries (CTEs, window functions) · `load_data.py` · `create_indexes.py` · `export_for_tableau.py` · `dashboard/` summary CSVs
