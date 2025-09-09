SELECT * FROM amazon.amazondata; 

alter table amazondata
modify Date date;

UPDATE amazondata
SET date = STR_TO_DATE(Date, '%m/%d/%Y');

ALTER TABLE amazondata
ADD COLUMN temp_date DATE;

UPDATE amazondata
SET temp_date = STR_TO_DATE(Date, '%m/%d/%Y');

alter table amazondata

drop column Date;

alter table amazondata
change temp_date date DATE;

alter table amazondata

add column time_of_day varchar(20);

update amazondata 

set time_of_day= case

when hour(Time) < 12 then 'Morning'
when hour(Time) < 18 then 'Afternoon'
else 'Evening'

end;

alter table amazondata
add column day_name varchar(20);

update amazondata 

set day_name= DAYNAME(date);


alter table amazondata

add column month_name varchar(20);

update amazondata

set month_name= left(monthname(date), 3);

----------------------------------------------------


-- 1.What is the count of distinct cities in the dataset?

SELECT 
    COUNT(DISTINCT (city)) AS Total_Distinct_cities
FROM
    amazondata;

-----------------------------

-- 2.For each branch, what is the corresponding city?

SELECT 
    branch, city
FROM
    amazondata
GROUP BY 1 , 2;

--------------------------------


-- 3.What is the count of distinct product lines in the dataset?  


SELECT 
    COUNT(DISTINCT (product_line)) AS TOTAL_PRODUCT_LINE
FROM
    amazondata;

---------------------------------

-- 4.Which payment method occurs most frequently?


SELECT DISTINCT
    (payment_method), COUNT(*) AS frequency
FROM
    amazondata
GROUP BY 1;

--------------------------------

-- 5.Which product line has the highest sales?


SELECT 
    product_line, SUM(total) AS total_sale
FROM
    amazondata
GROUP BY 1
ORDER BY total_sale DESC;

-----------------------------

-- 6.How much revenue is generated each month?


SELECT 
    month_name AS Month, SUM(total) AS total_revenue
FROM
    amazondata
GROUP BY 1
ORDER BY FIELD(month_name, 'Jan', 'Feb', 'Mar');

-------------------------------

-- 7.In which month did the cost of goods sold reach its peak?

SELECT 
    month_name AS month, SUM(cogs) AS cost_of_goods_sold
FROM
    amazondata
GROUP BY 1
ORDER BY cost_of_goods_sold DESC
LIMIT 1;
-------------------------------------

-- 8.Which product line generated the highest revenue?



SELECT 
    product_line, SUM(total) AS revenue
FROM
    amazondata
GROUP BY 1
ORDER BY revenue DESC
LIMIT 1;
-------------------------------------

-- 9.In which city was the highest revenue recorded?


SELECT 
    city, SUM(total) AS revenue
FROM
    amazondata
GROUP BY 1
ORDER BY revenue DESC
LIMIT 1;
-------------------------------

-- 10.Which product line incurred the highest Value Added Tax?


SELECT 
    product_line, SUM(vat) AS tax
FROM
    amazondata
GROUP BY 1
ORDER BY tax DESC
;

----------------------------------

-- 11.For each product line, add a column indicating "Good" if its sales are above average,
-- otherwise "Bad."


SELECT 
    product_line, 
    SUM(total) AS total_sales, avg(total) as avg_total, 
    CASE 
        WHEN SUM(total) > (SELECT AVG(subquery.total_sales) 
                           FROM (SELECT SUM(total) AS total_sales 
                                 FROM amazondata 
                                 GROUP BY product_line) AS subquery)
        THEN 'Good' 
        ELSE 'Bad' 
    END AS sales_status
FROM 
    amazondata
GROUP BY 
    product_line;

--------------------------------

-- 12.Identify the branch that exceeded the average number of products sold.


with branchsales as(
SELECT branch, sum(quantity) as total_product_sold
FROM amazondata GROUP BY 1 ),

avg_sales as(
SELECT avg(total_product_sold) as avg_product_sold
FROM branchsales) 

SELECT branch, total_product_sold FROM branchsales
WHERE total_product_sold > (SELECT avg_product_sold FROM avg_sales);

-----------------------------------

-- 13.Which product line is most frequently associated with each gender?

WITH GenderProductCount AS (
  SELECT 
    gender, 
    product_line, 
    COUNT(*) AS product_count
  FROM 
    amazondata
  GROUP BY 
    gender, 
    product_line
)
SELECT 
  gender, 
  product_line, 
  product_count
FROM 
  GenderProductCount g1
WHERE 
  product_count = (
    SELECT MAX(product_count)
    FROM GenderProductCount g2
    WHERE g1.gender = g2.gender
  );

--------------------------

-- 14.Calculate the average rating for each product line.


SELECT 
    product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM
    amazondata
GROUP BY 1;
-------------------------------

-- 15.Count the sales occurrences for each time of day on every weekday.


SELECT 
    day_name, time_of_day, COUNT(*) AS sales_count
FROM
    amazondata
GROUP BY 1 , 2
ORDER BY FIELD(day_name,
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday') , FIELD(time_of_day,
        'Morning',
        'Afternoon',
        'Evening');

------------------------------

-- 16.Identify the customer type contributing the highest revenue.


SELECT 
    customer_type, SUM(total) AS total_revenue
FROM
    amazondata
GROUP BY 1;
----------------------------------

-- 17.Determine the city with the highest VAT percentage.


SELECT 
    city,
    CONCAT(ROUND(SUM(vat) / SUM(total) * 100, 2),
            '%') AS vat_percentage
FROM
    amazondata
GROUP BY 1
ORDER BY vat_percentage DESC;

-----------------------------

-- 18.Identify the customer type with the highest VAT payments.


SELECT 
    customer_type, SUM(vat) AS vat_payment
FROM
    amazondata
GROUP BY 1;

-------------------------------

-- 19.What is the count of distinct customer types in the dataset?


SELECT 
    COUNT(DISTINCT customer_type) AS distinct_customer_type_count
FROM
    amazondata;

--------------------------------

-- 20.What is the count of distinct payment methods in the dataset?


SELECT 
    COUNT(DISTINCT (payment_method)) AS total_distinct_payment_method
FROM
    amazondata;
----------------------------------

-- 21.Which customer type occurs most frequently?


SELECT 
    customer_type, COUNT(*) AS customer_frequency
FROM
    amazondata
GROUP BY 1;

---------------------------

- 22.Identify the customer type with the highest purchase frequency.

SELECT 
    customer_type,
    COUNT(invoice_id) AS customer_purchase_frequency
FROM
    amazondata
GROUP BY 1;

----------------------------

-- 23.Determine the predominant gender among customers.


SELECT 
    gender, COUNT(*) AS count
FROM
    amazondata
GROUP BY 1;

----------------------------------------

-- 24.Examine the distribution of genders within each branch.


SELECT 
    branch, gender, COUNT(*) AS distribution
FROM
    amazondata
GROUP BY 1 , 2
ORDER BY FIELD(branch, 'A', 'B', 'C');

-----------------------------------------

-- 25.Identify the time of day when customers provide the most ratings.

SELECT 
    time_of_day,count(rating) AS ratings
FROM
    amazondata
WHERE
    rating IS NOT NULL
GROUP BY 1
ORDER BY ratings DESC;

-------------------------------------

-- 26.Determine the time of day with the highest customer ratings for each branch.

SELECT DISTINCT
    (branch), time_of_day, COUNT(rating) AS ratings_count
FROM
    amazondata
GROUP BY 1 , 2
ORDER BY 3 DESC
LIMIT 3;

----------------------------------

-- 27.Identify the day of the week with the highest average ratings.

SELECT 
    day_name, round(AVG(rating), 2) AS avg_rating
FROM
    amazondata
WHERE
    rating IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

------------------------------------

-- 28.Determine the day of the week with the highest average ratings for each branch.


SELECT 
    branch,
    day_name,
    ROUND(AVG(rating), 2) AS highest_avg_rating
FROM
    amazondata
GROUP BY 1 , 2
ORDER BY 3 DESC
LIMIT 3;

