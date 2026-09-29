-- 1. Total sales and profit overall
SELECT SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM Financial_Sample;

-- 2. Segment with highest total profit
SELECT segment, SUM(Profit) AS total_profit
FROM Financial_Sample
GROUP BY Segment
ORDER BY total_profit DESC
LIMIT 1;

-- 3. Profit margin (%) per product
SELECT Product,
       SUM(Profit) AS total_profit,
       SUM(Sales) AS total_sales,
       ROUND(SUM(Profit) * 100.0 / NULLIF(SUM(Sales), 0), 2) AS profit_margin_pct
FROM Financial_Sample
GROUP BY Product
ORDER BY profit_margin_pct DESC;

-- 4. Country with highest total sales
SELECT Country, SUM(Sales) AS total_sales
FROM Financial_Sample
GROUP BY Country
ORDER BY total_sales DESC
LIMIT 1;

-- 5. Month-over-month sales trend
SELECT `Month Number`, `Month Name`, SUM(Sales) AS monthly_sales
FROM Financial_Sample
GROUP BY `Month Number`, `Month Name`
ORDER BY `Month Number`;

-- 6. Segment with highest average profit per unit sold
SELECT Segment,
       ROUND(SUM(Profit) / NULLIF(SUM(`Units Sold`), 0), 2) AS avg_profit_per_unit
FROM Financial_Sample
GROUP BY Segment
ORDER BY avg_profit_per_unit DESC;

-- 7. Rank segments by total sales
SELECT Segment,
       SUM(Sales) AS total_sales,
       RANK() OVER (ORDER BY SUM(Sales) DESC) AS sales_rank
FROM Financial_Sample
GROUP BY Segment;

-- 8. Top 5 highest-profit transactions
SELECT *
FROM Financial_Sample
ORDER BY Profit DESC
LIMIT 5;

-- 9. YoY profit growth by segment
WITH yearly AS (
  SELECT Segment, Year, SUM(Profit) AS yr_profit
  FROM Financial_Sample
  GROUP BY Segment, Year
)
SELECT Segment, Year, yr_profit,
       LAG(yr_profit) OVER (PARTITION BY Segment ORDER BY Year) AS prev_year_profit,
       ROUND((yr_profit - LAG(yr_profit) OVER (PARTITION BY Segment ORDER BY Year)) * 100.0
             / NULLIF(LAG(yr_profit) OVER (PARTITION BY Segment ORDER BY Year), 0), 2) AS yoy_growth_pct
FROM yearly
ORDER BY Segment, Year;

-- 10. Loss-making country-segment combinations
SELECT Country, Segment, SUM(Profit) AS total_profit
FROM Financial_Sample
GROUP BY Country, Segment
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC;

-- 11. Running total of profit over time
SELECT Date, Segment, Profit,
       SUM(Profit) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_profit
FROM Financial_Sample
ORDER BY Date;

-- 12. Segments with profit margin < 10%
SELECT Segment,
       ROUND(SUM(Profit) * 100.0 / NULLIF(SUM(Sales), 0), 2) AS profit_margin_pct,
       CASE WHEN SUM(Profit) * 100.0 / NULLIF(SUM(Sales), 0) < 10 
            THEN 'Needs Review' ELSE 'OK' END AS status
FROM Financial_Sample
GROUP BY Segment;