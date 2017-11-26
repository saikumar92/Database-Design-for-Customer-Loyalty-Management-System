-- 1. Outlets with most check-ins

SELECT
    COUNT(customer_id),
    outlet_id
FROM
    check_in
GROUP BY
    outlet_id
ORDER BY COUNT(customer_id) DESC;



-- 2. Query to see if there is any correlation between the Bill Value and the amount of points redeemed

SELECT
    customer_id,
    outlet_id,
    bill_value,
    points_redeemed,
    TO_CHAR(
        points_redeemed / bill_value * 100,
        '99.99'
    ) AS percentredeemed
FROM
    transaction_redeem
ORDER BY percentredeemed DESC;



-- 3. Number of outlets and total customers for each vendor

SELECT
    vendor.name,
    COUNT(outlet.id) AS numoutlets,
    COUNT(customer_id) AS numcustomers
FROM
    outlet
    JOIN vendor ON outlet.vendor_id = vendor.id
    JOIN transaction_redeem ON outlet.id = transaction_redeem.outlet_id
GROUP BY
    vendor.id,
    vendor.name
ORDER BY numoutlets DESC;



-- 4. Average Age of customer base for each vendor

SELECT
    vendor.name AS vendor_name,
    COUNT(customer_id) AS numcustomers,
    AVG(2017 - EXTRACT(YEAR FROM date_of_birth) ) AS avgage
FROM
    outlet
    JOIN vendor ON outlet.vendor_id = vendor.id
    JOIN transaction_redeem ON outlet.id = transaction_redeem.outlet_id
    JOIN customer ON transaction_redeem.customer_id = customer.id
GROUP BY
    vendor.id,
    vendor.name
ORDER BY vendor.name;



-- 5. Query to get the Top Spending Customers and the Amount they Spent

SELECT
    table1.id,
    table1.first_name,
    table1.last_name,
    ( table1.amtspent + table2.amtspent ) AS totalamtspent
FROM (
    (
        SELECT
            customer.id,
            customer.first_name,
            customer.last_name,
            SUM(transaction_add.bill_value) AS amtspent
        FROM
            customer
            JOIN transaction_add ON customer.id = transaction_add.customer_id
        GROUP BY
            customer.id,
            customer.first_name,
            customer.last_name
        ORDER BY amtspent DESC
    ) table1
    LEFT JOIN (
        SELECT
            customer.id,
            customer.first_name,
            customer.last_name,
            SUM(transaction_redeem.bill_value) AS amtspent
        FROM
            customer
            JOIN transaction_redeem ON customer.id = transaction_redeem.customer_id
        GROUP BY
            customer.id,
            customer.first_name,
            customer.last_name
        ORDER BY amtspent DESC
    ) table2 ON table1.id = table2.id
);



-- 6. Points Added and Redeemed by each customer

SELECT
    table1.id,
    table1.first_name,
    table1.last_name,
    pointsadd,
    pointsredeem
FROM (
    (
        SELECT
            customer.id,
            customer.first_name,
            customer.last_name,
            SUM(transaction_add.points_added) AS pointsadd
        FROM
            customer
            JOIN transaction_add ON customer.id = transaction_add.customer_id
        GROUP BY
            customer.id,
            customer.first_name,
            customer.last_name
        ORDER BY pointsadd DESC
    ) table1
    LEFT JOIN (
        SELECT
            customer.id,
            customer.first_name,
            customer.last_name,
            SUM(transaction_redeem.points_redeemed) AS pointsredeem
        FROM
            customer
            JOIN transaction_redeem ON customer.id = transaction_redeem.customer_id
        GROUP BY
            customer.id,
            customer.first_name,
            customer.last_name
        ORDER BY pointsredeem DESC
    ) table2 ON table1.id = table2.id
);