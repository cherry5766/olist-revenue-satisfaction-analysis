# Memo: Late Deliveries and Customer Reviews at Olist

**To:** Operations leadership  
**From:** Inti Charan Kumar  
**Data:** Olist public dataset, delivered orders, Jan 2017 – Aug 2018 (about 96,000 orders)

## The problem
Revenue grew quickly through 2017 and flattened in 2018. Delivery performance is the one lever in the data that is strongly tied to customer satisfaction.

## What the data shows
- Only about 8% of delivered orders arrived after the promised date.
- Those orders are rated far lower. Orders 8+ days late average 1.73 stars vs 4.29 for on-time orders, and 78.4% of them give 1–2 stars (9.2% for on-time orders).
- Ratings fall sharply once an order is more than 3 days late (3.77 stars at 1–3 days, 2.32 at 4–7 days).
- Late rates differ by state. Network average: 8.1%. RJ (second-largest revenue state, 13.3% of revenue): 13.5%, with 1,664 late orders out of 12,310. BA: 14.0%, CE: 15.4%, MA: 19.6%.

## Recommendation
1. **Fix delivery performance in RJ first.** It has the largest number of late orders to remove. Matching the network rate would avoid about 663 late orders in this period (modeled estimate; BA 193, CE 92, ES 82, MA 82).
2. **Flag orders running 3+ days late** so customer service can contact the buyer before the delivery, since ratings drop sharply after that point.
3. **Review delivery promises in MA, CE and BA**, where late rates are highest, to see whether estimates are too optimistic.
4. **Track monthly on-time % and the share of 1–2 star reviews by state.**

## Risks and limits
- The link between lateness and low reviews is an association. Late orders may also differ by seller, product or region.
- "Late" is measured against Olist's own estimated delivery date, so a longer promise would reduce late flags without making delivery faster.
- The 663-order figure is a what-if calculation, not a measured result. It assumes RJ could reach the network average.
- The dataset ends in Aug 2018 and has no cost data, so this memo does not estimate cost or return on investment.
- States are customer states, not seller or warehouse locations.

## Next step
Compare late rates by seller and product category within RJ to find where the delays come from before choosing a fix.
