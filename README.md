# Airbnb Paris Market Analysis

## Project Overview
This project analyses Airbnb listing data in Paris, France, to understand the city's short-term rental market. It explores listing distribution, pricing patterns, host activity, review activity, and availability.

The objective is to identify market patterns and generate insights that can support better understanding of Airbnb's listing landscape in Paris.

## Tools Used
- Microsoft Excel – Data cleaning and preparation
- MySQL – Data analysis and querying
- Power BI – Interactive dashboard and visualisation

## Dataset
- **Source:** [Inside Airbnb](https://insideairbnb.com/get-the-data/)
- **Location:** Paris, France
- **Records:** 43,334 listings
- **Data type:** Listing-level data

## Project Analysis

### 1. Market Overview
- Total listings and hosts
- Distribution of listings by room type
- Neighbourhood-wise listing distribution
- Average and median listing prices
- Price-range distribution
- Availability by room type

### 2. Host and Review Analysis
- Single-listing vs. multi-listing hosts
- Top 10 hosts by number of listings
- Recent review activity by room type
- Recent review activity by neighbourhood

### 3. Pricing and Availability Insights
- Average listing price by neighbourhood
- Average availability by neighbourhood
- Distribution of minimum-night requirements
- Median minimum nights by neighbourhood

## Key Findings

- The dataset contains **43,334 Airbnb listings** and **27,568 hosts**.
- Entire homes/apartments account for **37,958 listings**, making them the dominant room type.
- The average listing price is **€337.40**, while the median is **€218.00**.
- The €101–€200 price range contains the largest number of listings, with **14,157 listings**.
- **87.54% of hosts** have a single listing, while 12.46% manage multiple listings.
- Élysée has the highest average listing price among the neighbourhoods, at **€546.42**.

## Power BI Dashboard

The interactive dashboard contains three pages:
1. Market Overview
2. Host & Review Analysis
3. Pricing & Availability Insights

## Repository Structure

- `SQL/` – SQL analysis scripts
- `PowerBI/` – Power BI dashboard
- `Documentation/` – Detailed project documentation
- `Video/` – Dashboard walkthrough recording

## Important Limitations

This dataset contains listing-level information, not actual booking transactions. Therefore, it cannot directly measure actual occupancy, booking revenue, profitability, or booking conversion.

Availability represents calendar availability reported in the dataset and should not be interpreted as actual occupancy.

## Conclusion

This project demonstrates an end-to-end data analysis workflow, from data preparation and SQL-based analysis to interactive dashboard development and business insight generation.