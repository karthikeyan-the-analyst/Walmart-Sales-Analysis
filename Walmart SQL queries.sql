-- CREATE A DATABASE

CREATE DATABASE IF NOT EXISTS WalmartSales;

-- CREATE A TABLE 

CREATE TABLE sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    vat FLOAT NOT NULL,
    total DECIMAL (12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL(12,4),
    rating FLOAT
);
    
SELECT * FROM sales;

-- -------------------------------------------- FEATURE ENGINEEINNG --------------------------------------------

-- Adding time_of_day Column : 

SELECT time,
	(CASE 
	WHEN time BETWEEN  "00:00:00" AND "12:00:00" THEN "Morning"
	WHEN time BETWEEN  "12:01:00" AND "16:00:00" THEN "Afternoon"
	ELSE "Evening"
    END) AS time_of_day
from sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales 
SET time_of_day = 
	(CASE 
	WHEN time BETWEEN  "00:00:00" AND "12:00:00" THEN "Morning"
	WHEN time BETWEEN  "12:01:00" AND "16:00:00" THEN "Afternoon"
	ELSE "Evening"
    END);
    
    
-- Adding day_name Column : 

SELECT date,
	DAYNAME(date) AS day_name
    FROM sales;
    
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


-- Adding month_name Column : 

SELECT date,
	MONTHNAME(date) 
    FROM sales;
    
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- --------------------------------------------------------------------

-- 1. What are the unique cities does the data have?

SELECT DISTINCT city FROM sales;

-- 2.  In which city is each branch located ?

SELECT DISTINCT city, branch FROM sales;


-- --------------------------------------------------------------------
-- ---------------------------- Product Analysis-----------------------
-- --------------------------------------------------------------------

-- 1. What are the unique product lines does the data have?

SELECT DISTINCT product_line FROM sales;

-- 2. What is the most common payment method?

SELECT payment, Count(payment) AS cnt 
FROM sales GROUP BY payment ORDER BY cnt DESC;

-- 3. What is the most selling product line?

SELECT product_line, Count(product_line) AS pcnt 
FROM sales GROUP BY product_line ORDER BY pcnt DESC;

-- 4. What is the total revenue by month ?

SELECT month_name AS Month , ROUND(SUM(total),2) AS Total_Revenue 
FROM sales GROUP BY Month ORDER BY Total_Revenue DESC;

-- 5. Which month had the highest COGS?

SELECT month_name AS Month , SUM(cogs) AS total_cogs 
FROM sales GROUP BY month_name ORDER BY total_cogs DESC;

-- 6. Which product line had the largest revenue?

SELECT product_line, SUM(total) AS Total_Revenue
FROM sales GROUP BY product_line ORDER BY Total_Revenue DESC;

-- 7. What is the city with the largest revenue?

SELECT city, SUM(total) AS Total_Revenue
FROM sales GROUP BY city ORDER BY Total_Revenue DESC;

-- 8. What product line had the largest VAT?

SELECT product_line, ROUND(SUM(vat),2) AS Total_vat
FROM sales GROUP BY product_line ORDER BY Total_vat DESC;

-- 9. Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT product_line, ROUND(AVG(total),2) AS avg_sales,
(CASE
WHEN avg(total) > (SELECT avg(total) FROM sales) THEN "GOOD" ELSE "BAD"
END) AS Sales_Evaluation
FROM sales GROUP BY product_line;

-- 10. Which branch sold more products than average product sold?

SELECT branch, 	AVG(quantity) AS avg_qty
FROM sales GROUP BY branch HAVING avg_qty > (SELECT AVG(quantity) AS Avg_qty_sold FROM sales);

-- 11. What is the most common product line by gender?

SELECT gender, product_line, COUNT(gender) AS total_cnt
FROM sales GROUP BY product_line, gender ORDER BY total_cnt DESC;

-- 12. What is the average rating of each product line

SELECT product_line, ROUND(AVG(rating),3) AS Avg_Rating 
FROM sales GROUP BY product_line ORDER BY Avg_Rating DESC;


-- --------------------------------------------------------------------
-- ---------------------------- Sales Analysis-------------------------
-- --------------------------------------------------------------------

-- 1. Number of sales made in each time of the day per weekday 

SELECT time_of_day, day_name, COUNT(*) AS Total_Sales FROM sales
WHERE day_name IN ("MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY") GROUP BY day_name, time_of_day
ORDER BY 
	CASE day_name
		WHEN "MONDAY" THEN 1
		WHEN "TUESDAY" THEN 2
		WHEN "WEDNESDAY" THEN 3
		WHEN "THURSDAY" THEN 4
		WHEN "FRIDAY" THEN 5
    END,
Total_Sales DESC;

-- ----------- (OR) -----------

SELECT time_of_day, day_name, COUNT(*) AS Total_Sales 
FROM sales 
WHERE day_name IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY') 
GROUP BY day_name, time_of_day 
ORDER BY FIELD(day_name, 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'), Total_Sales DESC;


-- 2. Which of the customer types brings the most revenue?

SELECT customer_type, SUM(total) AS Total_Revenue
FROM sales GROUP BY customer_type ORDER BY Total_Revenue DESC;

-- 3. Number of sales made in each time of the day per weekend 

SELECT time_of_day, day_name, COUNT(*) AS Total_Sales 
FROM sales 
WHERE day_name IN ('SATURDAY', 'SUNDAY') 
GROUP BY day_name, time_of_day 
ORDER BY FIELD(day_name, 'SATURDAY', 'SUNDAY'), Total_Sales DESC;

-- 4. Which city has the largest tax percent / VAT (Value Added Tax) ?

SELECT city, ROUND(SUM(vat),2) AS Total_Vat 
FROM sales GROUP BY city ORDER BY Total_Vat DESC;


-- --------------------------------------------------------------------
-- -------------------------- Customers Analysis-----------------------
-- --------------------------------------------------------------------

-- 1. How many unique customer types does the data have?

SELECT DISTINCT customer_type FROM sales;

-- 2. How many unique payment methods does the data have?

SELECT DISTINCT payment FROM sales;


-- 3. What is the most common customer type?

SELECT customer_type, COUNT(*) AS cnt
FROM sales GROUP BY customer_type ORDER BY cnt DESC;

-- 4. Which time of the day do customers give most ratings per branch?

SELECT time_of_day, branch, AVG(rating) AS avg_ratings
FROM sales 
WHERE branch IN("A","B","C")
GROUP BY time_of_day, branch ORDER BY avg_ratings DESC;

-- 5. Which day fo the week has the best avg ratings?

SELECT day_name, ROUND(AVG(rating),3) AS avg_rating
FROM sales GROUP BY day_name ORDER BY avg_rating DESC;

-- -------------------------------------------------------------- THANKYOU-------------------------------------------------------------------- --
