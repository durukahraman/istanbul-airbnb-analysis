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

_To be completed: SQL analysis (Day 3), calendar-based occupancy (Day 4)._

## Key Findings

_To be completed (3 findings with numbers)._

Early observation: more than half (51%) of priced listings received no reviews in the last 12 months. The active market is 11,818 listings, about 43% of what the raw data suggests.

## Recommendation

_To be completed._

## Limitations

- **Snapshot data.** Results reflect a single date (25 September 2026), not a full-year history of listings.
- **Activity filter excludes new listings.** Listings opened recently that have not yet received a review are removed along with inactive ones.
- **Occupancy is estimated.** In the calendar, an unavailable day may be booked *or* blocked by the host, so occupancy figures are an upper-bound estimate.
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
