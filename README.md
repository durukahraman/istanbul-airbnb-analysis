# Istanbul Airbnb Market Analysis

Where should an investor enter Istanbul's short-term rental market?

## Business Question

An investor wants to enter Istanbul's short-term rental market.
Which districts and room types offer the best return?

"Best return" is measured as estimated annual revenue per listing
(median nightly price × estimated occupancy), not price alone:
a high nightly rate means little if the listing is rarely booked.

## Data

- **Source:** [Inside Airbnb](https://insideairbnb.com/get-the-data/), Istanbul snapshot of **25 September 2026** (CC BY 4.0)
- **Files:** `listings.csv` (detailed listings), `calendar.csv` (365-day availability)
- **Size:** 27,232 listings × 90 columns; 15 columns kept for this analysis
- **Currency:** prices are shown with a `$` sign in the raw file but are in **Turkish lira (TRY)**. The median price of 3,710 would be implausible in USD for Istanbul.
- **Geography:** `neighbourhood_cleansed` is at district (*ilçe*) level.

Raw data is not committed to this repo. Download the files above into `data/` to reproduce.

## Data Cleaning

| Step | Rule | Removed | Remaining |
|---|---|---:|---:|
| Raw data | 15 relevant columns selected | – | 27,232 |
| Missing price | `price` is empty | 2,679 (9.8%) | 24,553 |
| Inactive listings | no reviews in the last 12 months (`number_of_reviews_ltm == 0`) | 12,615 (51%) | 11,938 |
| Price outliers | above the 99th percentile (27,302 TRY/night) | 120 (1%) | **11,818** |

**Key decisions:**

- **Median instead of mean.** Prices are right-skewed: before cleaning, the mean was 6,022 TRY while the median was 3,710 TRY. A few very expensive listings pull the mean up, so all price comparisons use the median.
- **99th percentile instead of the IQR rule.** The IQR rule would cap prices at 11,923 TRY and remove 726 active listings (6%), including legitimate luxury properties. The 99th percentile removes clear data-entry errors (e.g. a listing priced at 4.99M TRY/night) while keeping the luxury segment.
- **No lower cap.** After removing inactive listings, the cheapest price is 542 TRY/night, which is realistic for a shared room or hostel bed.
- **Activity filter.** A listing with no reviews in 12 months is unlikely to be part of the market an investor would compete in.

The cleaned data is stored in SQLite (`data/airbnb.db`, table `listings`) for SQL analysis and exported as `data/listings_clean.csv` for Tableau.

## Methodology

1. **Cleaning (pandas):** see the table above; cleaned data written to SQLite.
2. **SQL analysis** (`sql/`, run from `notebooks/03_sql.ipynb`):
   - district summary with **median price computed via window functions** (SQLite has no `MEDIAN()`), validated against pandas
   - price by room type, superhost effect (entire homes only, to compare like with like)
   - share of listings priced above their district median but rated below the district average
   - **opportunity score** = price index × demand index, where demand = reviews per listing in the last 12 months (Istanbul = 1.00)
3. **Calendar analysis** (`notebooks/04_calendar.ipynb`): 4.3M calendar rows (365 days × 11,818 listings, 28 Sep 2026 – 28 Sep 2027).
   - **Occupancy = share of unavailable days in the next 30 days.** Longer windows are distorted: far-future dates look "unavailable" because many hosts only open their calendar a few months ahead.
   - **Estimated monthly revenue** = median price × 30-day occupancy × 30 (entire homes, districts with ≥30 listings). Not annualised, because seasonality cannot be read from this calendar.
4. **Robustness check:** both demand proxies (reviews and calendar) point to the same districts.

## Key Findings

1. **The active market is less than half of what it looks like.** 51% of priced listings received no reviews in the last 12 months. Only 11,818 of 27,232 listings (43%) are active, so the real competition is far smaller than headline numbers suggest.
2. **Kadıköy offers the best balance of demand and competition.** Entire homes in Kadıköy have 48% occupancy and an estimated ~65,400 TRY monthly revenue, close to Beyoğlu (51%, ~76,100 TRY) but with one-fifth of the competition (720 vs 3,915 listings). Kadıköy also has the highest review-based demand among large districts (1.57× the Istanbul average) and the lowest share of overpriced, under-rated listings (4.7%).
3. **A higher price does not mean a better investment.** Şişli has one of the highest median prices (5,665 TRY/night) but the lowest occupancy among large districts (36%) and a demand index of 0.62. It looks saturated.

Supporting result: among entire homes, **superhosts charge 38% more** (median 5,657 vs 4,110 TRY). This is a correlation, not proof that superhost status causes higher prices.

## Recommendation

**Target entire homes in Kadıköy and run them to superhost standards.** Kadıköy combines strong demand, below-average prices (room to grow) and far less competition than Beyoğlu. Beyoğlu is the higher-revenue but more crowded alternative; Şişli should be avoided despite its high prices. Before investing, the estimates should be checked against property purchase prices or rents, which this data does not include.

## Limitations

- **Snapshot data.** Results reflect a single date (25 September 2026), not a full-year history of listings.
- **Activity filter excludes new listings.** Listings opened recently that have not yet received a review are removed along with inactive ones.
- **Occupancy is estimated.** In the calendar, an unavailable day may be booked *or* blocked by the host, so occupancy figures are an upper-bound estimate.
- **No seasonality.** The calendar is forward-looking and distorted beyond ~30 days, so revenue reflects the October–November period only. Seasonal districts (e.g. Adalar, ranked #1 by reviews but low in October occupancy) may be under- or over-estimated.
- **Small districts are unreliable.** Sarıyer ranks #1 by estimated revenue but has only 31 entire homes; a few luxury properties can drive the result.
- **No cost data.** Revenue is gross; purchase price, rent, fees and taxes are not included, so this is not a return-on-investment calculation.
- **Reviews as a demand proxy.** Review-writing habits may differ between guest types; this is why the calendar was used as a second check.
- **Listed price ≠ paid price.** Discounts, cleaning fees and seasonal pricing are not captured.

## Dashboard

_To be added: Tableau Public link and screenshot._

## Repository Structure

```
istanbul-airbnb-analysis/
├── data/          # raw and cleaned data (not committed)
├── notebooks/
│   ├── 01_explore.ipynb
│   └── 02_clean.ipynb
├── sql/           # one file per analysis query
├── dashboard/     # Tableau screenshot
└── environment.yml
```

## How to Reproduce

```bash
conda env create -f environment.yml
conda activate airbnb
# download listings.csv and calendar.csv into data/
jupyter notebook
```
