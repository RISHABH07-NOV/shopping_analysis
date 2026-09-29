--Showing all data
SELECT * FROM CUSTOMER;

--Overall business KPIs
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS average_order_value,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(AVG(profit)::NUMERIC, 2) AS average_profit
FROM customer;

--Sales by category
SELECT
    category,
    COUNT(*) AS total_orders,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS average_purchase
FROM customer
GROUP BY category
ORDER BY total_revenue DESC;

--Seasonal purchasing behavior
SELECT
    season,
    COUNT(*) AS total_orders,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS average_purchase
FROM customer
GROUP BY season
ORDER BY total_revenue DESC;

--Customer segmentation
SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount), 2) AS average_purchase,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(AVG(profit)::NUMERIC, 2) AS average_profit
FROM customer
GROUP BY customer_segment
ORDER BY total_revenue DESC;

--Return rate by category
SELECT
    category,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE return_status = 'Returned') AS returned_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE return_status = 'Returned')
        / COUNT(*),
        2
    ) AS return_rate_percentage
FROM customer
GROUP BY category
ORDER BY return_rate_percentage DESC;

--Subscription analysis
SELECT
    subscription_status,
    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount), 2) AS average_purchase,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(AVG(profit)::NUMERIC, 2) AS average_profit,
    ROUND(AVG(previous_purchases), 2) AS average_previous_purchases
FROM customer
GROUP BY subscription_status
ORDER BY average_purchase DESC;

--Gender-wise spending
SELECT
    gender,
    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount), 2) AS average_purchase,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY gender
ORDER BY total_revenue DESC;

--Age_Group-wise purchasing behavior
SELECT
    age_group,
    COUNT(*) AS orders,
    ROUND(AVG(purchase_amount), 2) AS average_purchase
FROM customer
GROUP BY age_group
ORDER BY age_group;

--Return rate
SELECT
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE return_status = 'Returned')
        / COUNT(*),
        2
    ) AS return_rate_percentage
FROM customer;

--Monthly revenue
SELECT
    DATE_TRUNC('month', purchase_date) AS month,
    COUNT(*) AS orders,
    ROUND(SUM(purchase_amount), 2) AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2) AS profit
FROM customer
GROUP BY DATE_TRUNC('month', purchase_date)
ORDER BY month;

--Top 5 products from each category
SELECT
    category,
    item_purchased,
    purchase_count,
    product_rank
FROM (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS purchase_count,
        RANK() OVER (
            PARTITION BY category
            ORDER BY COUNT(*) DESC
        ) AS product_rank
    FROM customer
    GROUP BY category, item_purchased
) ranked_products
WHERE product_rank <= 5
ORDER BY category, product_rank;

--Most profitable products
SELECT
    item_purchased,
    COUNT(*) AS orders,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit
FROM customer
GROUP BY item_purchased
ORDER BY total_profit DESC
LIMIT 10;

--Customer ranking
SELECT
    customer_id,
    SUM(purchase_amount) AS total_spending,
    RANK() OVER (
        ORDER BY SUM(purchase_amount) DESC
    ) AS spending_rank
FROM customer
GROUP BY customer_id;

--Top customers by category
SELECT *
FROM (
    SELECT
        category,
        customer_id,
        SUM(purchase_amount) AS total_spending,
        RANK() OVER (
            PARTITION BY category
            ORDER BY SUM(purchase_amount) DESC
        ) AS rank
    FROM customer
    GROUP BY category, customer_id
) ranked_customers
WHERE rank <= 3
ORDER BY category, rank;

--which customer use the discount but still spend more than the average purchase amount ? 
SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount >= (
      SELECT AVG(purchase_amount)
      FROM customer
  );
-- top 5 products with the highest average review rating
SELECT
    item_purchased,
    ROUND(AVG(review_rating)::Numeric, 2) AS avg_review_rating
FROM customer
GROUP BY item_purchased
ORDER BY avg_review_rating DESC
LIMIT 5;

--are customer which have more than 5 previous purchases are likely to subscribe ?
SELECT
    CASE
        WHEN previous_purchases > 5 THEN 'More than 5'
        ELSE '5 or fewer'
    END AS purchase_group,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE subscription_status = 'Yes'
    ) AS subscribed_customers,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE subscription_status = 'Yes'
        ) / COUNT(*),
        2
    ) AS subscription_rate

FROM customer

GROUP BY
    CASE
        WHEN previous_purchases > 5 THEN 'More than 5'
        ELSE '5 or fewer'
    END

ORDER BY subscription_rate DESC;
