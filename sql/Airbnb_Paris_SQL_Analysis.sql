-- =====================================================
-- AIRBNB PARIS MARKET ANALYSIS
-- SECTION 1: MARKET OVERVIEW
-- SECTION 1.1: OVERALL MARKET STATISTICS
-- =====================================================

-- Business Question:
-- How large is the Airbnb market in Paris?
-- What are its basic pricing and availability characteristics?
SELECT
    COUNT(*) AS total_listings,
    COUNT(DISTINCT host_id) AS total_hosts,
    COUNT(DISTINCT neighbourhood) AS total_neighbourhoods,
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    ROUND(AVG(availability_365), 2) AS average_availability
FROM airbnb_paris.listings;

-- =====================================================
-- SECTION 1.2: ROOM-TYPE DISTRIBUTION
-- =====================================================

-- Business Question:
-- Which room types dominate the Airbnb market in Paris?
-- What percentage of total listings does each room type represent?
SELECT
    room_type,
    COUNT(*) AS total_listings,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM airbnb_paris.listings),
        2
    ) AS market_share_percentage
FROM airbnb_paris.listings
GROUP BY room_type
ORDER BY total_listings DESC;

-- =====================================================
-- SECTION 1.3: NEIGHBOURHOOD MARKET DISTRIBUTION
-- =====================================================

-- Business Questions:
-- Which neighbourhoods have the highest number of listings?
-- How do average listing prices differ across neighbourhoods?
SELECT
    neighbourhood,
    COUNT(*) AS total_listings,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM airbnb_paris.listings), 2
    ) AS market_share_percentage,
    ROUND(AVG(price), 2) AS average_price
FROM airbnb_paris.listings
GROUP BY neighbourhood
ORDER BY total_listings DESC;

-- =====================================================
-- SECTION 1.4: PRICE DISTRIBUTION
-- =====================================================

-- Business Question:
-- What is the median listing price?
-- How does it compare with the average listing price?
WITH ranked_prices AS (
    SELECT
        price,
        ROW_NUMBER() OVER (ORDER BY price) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM airbnb_paris.listings
)
SELECT
    ROUND(AVG(price), 2) AS median_price
FROM ranked_prices
WHERE row_num IN (
    FLOOR((total_rows + 1) / 2),
    FLOOR((total_rows + 2) / 2)
);

-- =====================================================
-- SECTION 1.5: PRICE RANGE DISTRIBUTION
-- =====================================================

-- Business Question:
-- How are Airbnb listings distributed across different price ranges?
-- Which price range contains the largest number of listings?
SELECT
    CASE
        WHEN price <= 100 THEN '€0–100'
        WHEN price <= 200 THEN '€101–200'
        WHEN price <= 300 THEN '€201–300'
        WHEN price <= 500 THEN '€301–500'
        ELSE 'Above €500'
    END AS price_range,
    COUNT(*) AS total_listings,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM airbnb_paris.listings),
        2
    ) AS percentage
FROM airbnb_paris.listings
GROUP BY price_range
ORDER BY MIN(price);

-- =====================================================
-- SECTION 1.6: NEIGHBOURHOOD-WISE PRICING ANALYSIS
-- =====================================================

-- Objective:
-- Compare Airbnb listing prices across Paris neighbourhoods.

-- Purpose:
-- Identify expensive and affordable neighbourhoods
-- and understand geographical pricing differences.

-- Business Questions:
-- Which neighbourhoods have the highest average prices?
-- Which neighbourhoods have the lowest average prices?
-- How much do prices vary across neighbourhoods?
SELECT
    neighbourhood,
    COUNT(*) AS total_listings,
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM airbnb_paris.listings
GROUP BY neighbourhood
ORDER BY average_price DESC;

-- =====================================================
-- SECTION 1.7: ROOM-TYPE-WISE PRICING ANALYSIS
-- =====================================================

-- Objective:
-- Compare Airbnb listing prices across different room types.

-- Purpose:
-- Understand pricing differences between accommodation types
-- and identify the most and least expensive room categories.

-- Business Questions:
-- Which room type has the highest average price?
-- Which room type has the lowest average price?
-- How many listings belong to each room type?
-- How much do prices vary between room types?
SELECT
    room_type,
    COUNT(*) AS total_listings,
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    ROUND(AVG(availability_365), 2) AS average_availability
FROM airbnb_paris.listings
GROUP BY room_type
ORDER BY average_price DESC;

-- =====================================================
-- SECTION 1.8: NEIGHBOURHOOD AND ROOM-TYPE ANALYSIS
-- =====================================================

-- Objective:
-- Analyse the distribution of room types across neighbourhoods.

-- Purpose:
-- Identify dominant accommodation types in each neighbourhood
-- and understand geographical differences in Airbnb supply.

-- Business Questions:
-- Which room type is most common in each neighbourhood?
-- Which neighbourhood has the highest number of entire homes?
-- Which neighbourhood has the highest number of private rooms?
-- How does room-type distribution vary across neighbourhoods?
SELECT
    neighbourhood,
    room_type,
    COUNT(*) AS total_listings,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY neighbourhood),
        2
    ) AS room_type_percentage
FROM airbnb_paris.listings
GROUP BY neighbourhood, room_type
ORDER BY neighbourhood, total_listings DESC;

-- =====================================================
-- SECTION 1.9: HOST LISTING ANALYSIS
-- =====================================================

-- Objective:
-- Analyse the distribution of Airbnb listings among hosts.

-- Purpose:
-- Identify single-listing and multi-listing hosts,
-- examine large host portfolios, and measure listing concentration.

-- Business Questions:
-- How many hosts manage only one listing?
-- How many hosts manage multiple listings?
-- Who are the top 10 hosts by listing count?
-- What percentage of total listings belongs to the top 10 hosts?
SELECT
    CASE
        WHEN host_listing_count = 1 THEN 'Single-listing host'
        ELSE 'Multi-listing host'
    END AS host_category,
    COUNT(*) AS total_hosts,
    SUM(host_listing_count) AS total_listings,
    ROUND(
        SUM(host_listing_count) * 100.0 /
        (SELECT COUNT(*) FROM airbnb_paris.listings),
        2
    ) AS listing_share_percentage
FROM (
    SELECT
        host_id,
        COUNT(*) AS host_listing_count
    FROM airbnb_paris.listings
    GROUP BY host_id
) AS host_summary
GROUP BY host_category;
SELECT
    host_id,
    host_name,
    COUNT(*) AS total_listings,
    ROUND(AVG(price), 2) AS average_price
FROM airbnb_paris.listings
GROUP BY host_id, host_name
ORDER BY total_listings DESC
LIMIT 10;
WITH host_listing_counts AS (
    SELECT
        host_id,
        COUNT(*) AS total_listings
    FROM airbnb_paris.listings
    GROUP BY host_id
),
top_10_hosts AS (
    SELECT
        host_id,
        total_listings
    FROM host_listing_counts
    ORDER BY total_listings DESC
    LIMIT 10
)
SELECT
    SUM(total_listings) AS top_10_total_listings,
    ROUND(
        SUM(total_listings) * 100.0 /
        (SELECT COUNT(*) FROM airbnb_paris.listings),
        2
    ) AS market_share_percentage
FROM top_10_hosts;

-- =====================================================
-- SECTION 1.10: AVAILABILITY ANALYSIS
-- =====================================================

-- Objective:
-- Analyse Airbnb calendar availability across Paris.

-- Purpose:
-- Compare availability between neighbourhoods and room types
-- and identify areas with higher or lower calendar availability.

-- Business Questions:
-- Which neighbourhoods have the highest average availability?
-- Which neighbourhoods have the lowest average availability?
-- How does availability vary across room types?
SELECT
    neighbourhood,
    COUNT(*) AS total_listings,
    ROUND(AVG(availability_365), 2) AS average_availability,
    MIN(availability_365) AS minimum_availability,
    MAX(availability_365) AS maximum_availability
FROM airbnb_paris.listings
GROUP BY neighbourhood
ORDER BY average_availability DESC;
SELECT
    room_type,
    COUNT(*) AS total_listings,
    ROUND(AVG(availability_365), 2) AS average_availability,
    MIN(availability_365) AS minimum_availability,
    MAX(availability_365) AS maximum_availability
FROM airbnb_paris.listings
GROUP BY room_type
ORDER BY average_availability DESC;

-- =====================================================
-- 1.11 REVIEW AND LISTING ACTIVITY ANALYSIS
-- =====================================================

-- Query 1: Review Activity by Room Type
-- Objective: Compare total and average review activity
-- across different Airbnb room types.
SELECT
    room_type,
    COUNT(*) AS total_listings,
    SUM(number_of_reviews) AS total_reviews,
    ROUND(AVG(number_of_reviews), 2) AS average_reviews_per_listing,
    SUM(number_of_reviews_ltm) AS reviews_last_12_months,
    ROUND(AVG(number_of_reviews_ltm), 2) AS average_reviews_last_12_months
FROM airbnb_paris.listings
GROUP BY room_type
ORDER BY total_reviews DESC;

-- Query 2: Check Missing Review Data
-- Objective: Identify missing values in review-related columns.
-- Purpose: Verify data completeness before interpreting averages.

SELECT
    COUNT(*) AS total_listings,
    SUM(number_of_reviews IS NULL) AS null_lifetime_reviews,
    SUM(number_of_reviews_ltm IS NULL) AS null_recent_reviews,
    SUM(reviews_per_month IS NULL) AS null_reviews_per_month,
    SUM(last_review IS NULL) AS null_last_review
FROM airbnb_paris.listings;

-- =====================================================
-- 1.11 REVIEW AND LISTING ACTIVITY ANALYSIS
-- =====================================================

-- Query 3: Neighbourhood-wise Review Activity
-- Objective: Compare review activity across neighbourhoods.
-- Purpose: Identify differences in total and average reviews.

SELECT
    neighbourhood,
    COUNT(*) AS total_listings,
    SUM(number_of_reviews) AS total_reviews,
    ROUND(AVG(number_of_reviews), 2) AS average_reviews_per_listing,
    SUM(number_of_reviews_ltm) AS reviews_last_12_months,
    ROUND(AVG(number_of_reviews_ltm), 2) AS average_recent_reviews
FROM airbnb_paris.listings
GROUP BY neighbourhood
ORDER BY total_reviews DESC;

-- =====================================================
-- 1.11 REVIEW AND LISTING ACTIVITY ANALYSIS
-- =====================================================

-- Query 4: Review Recency Analysis
-- Objective: Examine the year of the most recent review.
-- Purpose: Understand how recently listings received reviews.

SELECT
    YEAR(last_review) AS last_review_year,
    COUNT(*) AS total_listings
FROM airbnb_paris.listings
WHERE last_review IS NOT NULL
GROUP BY YEAR(last_review)
ORDER BY last_review_year DESC;
-- Query 4A: Inspect Last Review Date Format
-- Objective: Examine the stored review date values.
-- Purpose: Identify why YEAR() is returning NULL.

SELECT
    last_review,
    COUNT(*) AS total_listings
FROM airbnb_paris.listings
WHERE last_review IS NOT NULL
GROUP BY last_review
ORDER BY last_review DESC
LIMIT 10;
-- =====================================================
-- 1.11 REVIEW AND LISTING ACTIVITY ANALYSIS
-- =====================================================

-- Query 4: Review Recency Analysis
-- Objective: Group listings by the year of their last review.
-- Purpose: Analyse the recency of customer review activity.

SELECT
    YEAR(STR_TO_DATE(last_review, '%c/%e/%Y')) AS last_review_year,
    COUNT(*) AS total_listings
FROM airbnb_paris.listings
WHERE last_review IS NOT NULL
GROUP BY YEAR(STR_TO_DATE(last_review, '%c/%e/%Y'))
ORDER BY last_review_year DESC;
-- =====================================================
-- 1.12 MINIMUM-NIGHT REQUIREMENT ANALYSIS
-- =====================================================

-- Query 1: Overall Minimum-Night Statistics
-- Objective: Calculate overall minimum-night statistics.
-- Purpose: Understand minimum-stay requirements across Paris.

SELECT
    COUNT(*) AS total_listings,
    COUNT(minimum_nights) AS listings_with_minimum_nights,
    SUM(minimum_nights IS NULL) AS null_minimum_nights,
    ROUND(AVG(minimum_nights), 2) AS average_minimum_nights,
    MIN(minimum_nights) AS shortest_minimum_stay,
    MAX(minimum_nights) AS longest_minimum_stay
FROM airbnb_paris.listings;

-- =====================================================
-- 1.12 MINIMUM-NIGHT REQUIREMENT ANALYSIS
-- =====================================================

-- Query 2: Minimum-Night Distribution
-- Objective: Categorise listings by minimum-night requirements.
-- Purpose: Identify the most common minimum-stay ranges.

SELECT
    CASE
        WHEN minimum_nights IS NULL THEN 'Missing'
        WHEN minimum_nights = 1 THEN '1 Night'
        WHEN minimum_nights BETWEEN 2 AND 3 THEN '2-3 Nights'
        WHEN minimum_nights BETWEEN 4 AND 7 THEN '4-7 Nights'
        WHEN minimum_nights BETWEEN 8 AND 14 THEN '8-14 Nights'
        WHEN minimum_nights BETWEEN 15 AND 30 THEN '15-30 Nights'
        ELSE 'Above 30 Nights'
    END AS minimum_night_category,
    COUNT(*) AS total_listings,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM airbnb_paris.listings), 2)
        AS listing_percentage
FROM airbnb_paris.listings
GROUP BY minimum_night_category
ORDER BY
    CASE minimum_night_category
        WHEN '1 Night' THEN 1
        WHEN '2-3 Nights' THEN 2
        WHEN '4-7 Nights' THEN 3
        WHEN '8-14 Nights' THEN 4
        WHEN '15-30 Nights' THEN 5
        WHEN 'Above 30 Nights' THEN 6
        WHEN 'Missing' THEN 7
    END;
    -- Query 3: Average Minimum Nights by Category
-- Objective: Calculate average minimum nights within each category.
-- Purpose: Identify the influence of longer minimum-stay requirements.

SELECT
    CASE
        WHEN minimum_nights = 1 THEN '1 Night'
        WHEN minimum_nights BETWEEN 2 AND 3 THEN '2-3 Nights'
        WHEN minimum_nights BETWEEN 4 AND 7 THEN '4-7 Nights'
        WHEN minimum_nights BETWEEN 8 AND 14 THEN '8-14 Nights'
        WHEN minimum_nights BETWEEN 15 AND 30 THEN '15-30 Nights'
        ELSE 'Above 30 Nights'
    END AS minimum_night_category,
    COUNT(*) AS total_listings,
    ROUND(AVG(minimum_nights), 2) AS average_minimum_nights,
    MIN(minimum_nights) AS lowest_minimum_nights,
    MAX(minimum_nights) AS highest_minimum_nights
FROM airbnb_paris.listings
WHERE minimum_nights IS NOT NULL
GROUP BY minimum_night_category
ORDER BY MIN(minimum_nights);

-- Query 4: Median Minimum Nights
-- Objective: Calculate the median minimum-night requirement.
-- Purpose: Identify the typical minimum stay without distortion from extreme values.

WITH ordered_minimum_nights AS (
    SELECT
        minimum_nights,
        ROW_NUMBER() OVER (ORDER BY minimum_nights) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM airbnb_paris.listings
    WHERE minimum_nights IS NOT NULL
)
SELECT
    ROUND(AVG(minimum_nights), 2) AS median_minimum_nights
FROM ordered_minimum_nights
WHERE row_num IN (
    FLOOR((total_rows + 1) / 2),
    FLOOR((total_rows + 2) / 2)
);

-- Query 5: Neighbourhood-wise Median Minimum-Night Requirement
-- Objective: Calculate the median minimum-night requirement for each neighbourhood.
-- Purpose: Identify differences in typical minimum-stay requirements across Paris.

WITH ranked_listings AS (
    SELECT
        neighbourhood,
        minimum_nights,
        ROW_NUMBER() OVER (
            PARTITION BY neighbourhood
            ORDER BY minimum_nights
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY neighbourhood
        ) AS total_rows
    FROM airbnb_paris.listings
    WHERE minimum_nights IS NOT NULL
)

SELECT
    neighbourhood,
    MAX(total_rows) AS listings_with_minimum_nights,
    ROUND(
        AVG(
            CASE
                WHEN row_num IN (
                    FLOOR((total_rows + 1) / 2),
                    FLOOR((total_rows + 2) / 2)
                )
                THEN minimum_nights
            END
        ), 2
    ) AS median_minimum_nights
FROM ranked_listings
GROUP BY neighbourhood
ORDER BY median_minimum_nights;
-- Query 6: Verify Neighbourhood Coverage for Minimum-Night Analysis
-- Objective: Identify listings with missing neighbourhood values.
-- Purpose: Explain why the neighbourhood-level result does not include all valid listings.

SELECT
    COUNT(*) AS total_valid_minimum_night_listings,
    SUM(neighbourhood IS NULL OR TRIM(neighbourhood) = '') AS missing_neighbourhood,
    COUNT(DISTINCT neighbourhood) AS distinct_neighbourhoods
FROM airbnb_paris.listings
WHERE minimum_nights IS NOT NULL;
-- Query 7: Verify All Neighbourhoods in Minimum-Night Analysis
-- Objective: List all neighbourhoods and their valid minimum-night listing counts.
-- Purpose: Identify which neighbourhood was missing from the previous result.

SELECT
    neighbourhood,
    COUNT(*) AS listings_with_minimum_nights
FROM airbnb_paris.listings
WHERE minimum_nights IS NOT NULL
GROUP BY neighbourhood
ORDER BY neighbourhood;