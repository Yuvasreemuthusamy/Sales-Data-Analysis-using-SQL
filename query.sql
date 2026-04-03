use sales;
select *from order_sales;
-- 1.Which products generate the highest revenue, and how do they rank?
SELECT 
    Product,
    SUM(Quantity * Price) AS revenue,
    RANK() OVER (ORDER BY SUM(Quantity * Price) DESC) AS rank_position
FROM order_sales
GROUP BY Product;

-- 2. What is the top-performing product in each region?
SELECT *FROM (
    SELECT 
        Region,
        Product,
        SUM(Quantity * Price) AS revenue,
        RANK() OVER (PARTITION BY Region ORDER BY SUM(Quantity * Price) DESC) AS rnk
    FROM order_sales
    GROUP BY Region, Product
) t
WHERE rnk = 1;

-- 3. Which customers spend more than the average customer spending?
SELECT Customer_Name, SUM(Quantity * Price) AS total_spent
FROM order_sales
GROUP BY Customer_Name
HAVING total_spent > (
    SELECT AVG(Quantity * Price) FROM order_sales
);

-- 4.How does revenue accumulate over time (cumulative revenue)?
SELECT 
    Order_Date,
    SUM(Quantity * Price) AS daily_revenue,
    SUM(SUM(Quantity * Price)) OVER (ORDER BY Order_Date) AS cumulative_revenue
FROM order_sales
GROUP BY Order_Date;

-- 5.Which month has the highest sales revenue?
SELECT 
    MONTH(Order_Date) AS month,
    SUM(Quantity * Price) AS revenue
FROM order_sales
GROUP BY month
ORDER BY revenue DESC
LIMIT 1;

-- 6.How can orders be categorized into High, Medium, and Low value?
SELECT 
    Order_ID,
    (Quantity * Price) AS order_value,
    CASE 
        WHEN (Quantity * Price) > 50000 THEN 'High'
        WHEN (Quantity * Price) BETWEEN 20000 AND 50000 THEN 'Medium'
        ELSE 'Low'
    END AS order_category
FROM order_sales;

-- 7.Which customers are repeat buyers?
SELECT Customer_Name, COUNT(Order_ID) AS total_orders
FROM order_sales
GROUP BY Customer_Name
HAVING total_orders > 1;

-- 8.What percentage of total revenue does each region contribute?
SELECT 
    Region,
    SUM(Quantity * Price) AS revenue,
    ROUND(
        SUM(Quantity * Price) * 100.0 / 
        (SELECT SUM(Quantity * Price) FROM order_sales),
    2) AS percentage_contribution
FROM order_sales
GROUP BY Region;

-- 9.What is the highest-value order placed by each customer?
SELECT *
FROM (
    SELECT 
        Customer_Name,
        Order_ID,
        (Quantity * Price) AS order_value,
        ROW_NUMBER() OVER (PARTITION BY Customer_Name ORDER BY (Quantity * Price) DESC) AS rn
    FROM order_sales
) t
WHERE rn = 1;

-- 10.On which days did sales exceed the average daily sales?
SELECT 
    Order_Date,
    SUM(Quantity * Price) AS daily_sales
FROM order_sales
GROUP BY Order_Date
HAVING daily_sales > (
    SELECT AVG(daily_total)
    FROM (
        SELECT SUM(Quantity * Price) AS daily_total
        FROM order_sales
        GROUP BY Order_Date
    ) t
);