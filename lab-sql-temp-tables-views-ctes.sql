USE sakila;
DROP VIEW IF EXISTS rental_summary_test;# Use this to drop any view with the same name
CREATE VIEW rental_summary_test AS # It creates a view that summarizes rental information for each customer
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,# This concatenates the first and last name into a new column
    c.email,
    COUNT(r.rental_id) AS rental_count # It counts the number of rentals (rental_count) for each customer
FROM 
    customer c
JOIN 
    rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;

DROP TEMPORARY TABLE IF EXISTS payment_summary; #Use this to drop any view with the same name
CREATE TEMPORARY TABLE payment_summary AS #Uses the view rs to join with the payment table
SELECT 
    rs.customer_id,
    rs.customer_name,
    rs.email,
    rs.rental_count,
    SUM(p.amount) AS total_paid # Calculates the total payments made by each customer (total_paid)
FROM 
    rental_summary_test rs
JOIN 
    payment p ON rs.customer_id = p.customer_id
GROUP BY 
    rs.customer_id, rs.customer_name, rs.email, rs.rental_count;
    
    WITH customer_report AS ( # CTE joins the rs view with the ps temporary table.
    SELECT 
        ps.customer_name,
        ps.email,
        ps.rental_count,
        ps.total_paid,
        (ps.total_paid / ps.rental_count) AS avg_payment_per_rental # Calculates the average payment per rental 
    FROM 
        payment_summary ps
)
SELECT 
    customer_name, 
    email, 
    rental_count, 
    total_paid, 
    avg_payment_per_rental
FROM 
    customer_report;

