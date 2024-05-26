-- 1)Identify a table that voilates 1 NF in sakila and Explain how you can acheive it .
/* One table in the Sakila database that may violate the First Normal Form (1NF) is the film table
 due to the special_features column. In the Sakila database,
 the film table has a column named special_features that stores a comma-separated 
list of special features associated with each film.*/
CREATE TABLE film (
    film_id INT PRIMARY KEY,
    title VARCHAR(255),
    special_features VARCHAR(255) -- Violates 1NF
);
-- The Above one Violates the 1NF 
/* To achieve 1NF, you should avoid storing multiple values in a single column. 
Instead, you should normalize the data by creating a separate table for special features and establishing a
 one-to-many relationship between films and special features.
Here's how you could normalize the film table to achieve 1NF:*/
CREATE TABLE special_feature (
    feature_id INT PRIMARY KEY,
    feature_name VARCHAR(255)
);
CREATE TABLE film_special_feature (
    film_id INT,
    feature_id INT,
    PRIMARY KEY (film_id, feature_id),
    FOREIGN KEY (film_id) REFERENCES film(film_id),
    FOREIGN KEY (feature_id) REFERENCES special_feature(feature_id)
);
ALTER TABLE film
DROP COLUMN special_features;
/*Now, the data is normalized, and the film table adheres to 1NF. 
The relationship between films and special features is represented through the film_special_feature junction table. 
This approach separates the data into distinct tables, 
allowing for more efficient querying and avoiding the violation of 1NF*/



-- 2)Choose a table in Sakila and describe how you would determine whether it is in 2NF If it violates 2NF,explain the steps to Normalize it
/*
Let's consider the film table in the Sakila database for the discussion. In the Sakila database, the film table is typically related to other tables like language, category, and actor. If there are dependencies among non-primary key columns in the film table, we can analyze whether it violates the Second Normal Form (2NF).

The Second Normal Form (2NF) states that a table should be in 1NF, and all non-prime attributes (attributes not part of the primary key) should be fully functionally dependent on the entire primary key.

In the context of the film table, it might have multiple attributes, and for simplicity, let's consider two potential columns that might be related: category_id and language_id.

Here's a simplified representation of the film table:*/
CREATE TABLE film (
    film_id INT PRIMARY KEY,
    title VARCHAR(255),
    category_id INT,
    language_id INT,
    -- Other attributes
    FOREIGN KEY (category_id) REFERENCES category(category_id),
    FOREIGN KEY (language_id) REFERENCES language(language_id)
);
-- this will violates the 2 NF
/* Now, let's check for potential violations of 2NF:

Check for partial dependencies: Identify if any non-prime attribute depends on only part of the primary key.

In this case, both category_id and language_id are part of the primary key, so we don't have partial dependencies.

Check for transitive dependencies: Identify if any non-prime attribute depends on another non-prime attribute.

If, for example, category depended on another non-prime attribute that wasn't part of the primary key, we would have a transitive dependency.

Assuming there are no violations of 2NF in this example, let's consider a hypothetical violation for the sake of demonstration:*/
CREATE TABLE film (
    film_id INT PRIMARY KEY,
    title VARCHAR(255),
    category_name VARCHAR(255), -- Violates 2NF
    language_id INT,
    -- Other attributes
    FOREIGN KEY (language_id) REFERENCES language(language_id)
);
CREATE TABLE category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255)
);
ALTER TABLE film
ADD COLUMN category_id INT,
DROP COLUMN category_name,
ADD FOREIGN KEY (category_id) REFERENCES category(category_id);
-- 2NF is done.

 -- 3)Choose a table in Sakila and describe how you would determine whether it is in 3NF If it violates 3NF,explain the steps to Normalize it.
 /* Let's consider the film table in the Sakila database for the discussion. In the Sakila database, the film table is related to other tables such as category, language, and actor. To determine whether it is in Third Normal Form (3NF), we need to check for transitive dependencies.

The Third Normal Form (3NF) states that a table should be in 2NF, and no transitive dependencies should exist. In other words, every non-prime attribute (attributes not part of the primary key) should be directly dependent on the primary key.

For example, let's consider the following simplified representation of the film table */
CREATE TABLE film (
    film_id INT PRIMARY KEY,
    title VARCHAR(255),
    category_id INT,
    language_id INT,
    actor_name VARCHAR(255),
    -- Other attributes
    FOREIGN KEY (category_id) REFERENCES category(category_id),
    FOREIGN KEY (language_id) REFERENCES language(language_id)
);
-- This will violates the 3NF. This can be normalised by the following queries
CREATE TABLE actor (
    actor_id INT PRIMARY KEY,
    actor_name VARCHAR(255)
);
CREATE TABLE film_actor (
    film_id INT,
    actor_id INT,
    PRIMARY KEY (film_id, actor_id),
    FOREIGN KEY (film_id) REFERENCES film(film_id),
    FOREIGN KEY (actor_id) REFERENCES actor(actor_id)
);
ALTER TABLE film
DROP COLUMN actor_name;
/*Now, the film table adheres to 3NF, as the non-prime attributes (category_id and language_id) are directly dependent on the primary key, 
and the transitive dependency of actor_name has been eliminated through the introduction of the film_actor junction table.*/


-- 4)Take a specific table in Sakila and guide through the process of Normalizing it from the initial unnormalized form up to at least 2NF
-- Step 1: Initial Unnormalized Form (UNF)
CREATE TABLE rental (
    rental_id INT PRIMARY KEY,
    rental_date DATETIME,
    inventory_id INT,
    customer_id INT,
    return_date DATETIME,
    -- Other attributes
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
/*Step 2: Identify Partial Dependencies
No partial dependencies in this example.

Step 3: Identify Transitive Dependencies
No transitive dependencies in this example.

Step 4: Normalize to 1NF
The rental table is already in First Normal Form (1NF).

Step 5: Normalize to 2NF
The rental table is also already in Second Normal Form (2NF) since there are no partial dependencies on a composite primary key.

In this case, the rental table did not exhibit partial or transitive dependencies, 
so no further normalization was necessary. 
 there were such dependencies, additional tables would be created to eliminate them.
Please note that this example assumes a simplified scenario, 
and normalization steps may vary depending on the actual characteristics of your data and business requirements.*/

-- 5) Write a query using a CTE to retrieve the distinct list of actor Names and the Number of films they have acted in from the actor and film_actor tables
WITH ActorFilmCount AS (
    SELECT
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        COUNT(fa.film_id) AS film_count
    FROM
        actor a
    JOIN
        film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY
        a.actor_id, actor_name
)

SELECT
    actor_name,
    film_count
FROM
    ActorFilmCount
ORDER BY
    actor_name;

-- 6) Use a recursive CTE to generate a hierarchical list of categories and their subcategories from the category table in sakila
WITH RECURSIVE CategoryHierarchy AS (
  -- Anchor member: Select top-level categories (categories without a parent)
  SELECT fc.category_id, c.name, fc.category_id as parent_category_id, c.last_update
  FROM film_category fc
  JOIN category c ON fc.category_id = c.category_id
  WHERE fc.film_id NOT IN (SELECT DISTINCT film_id FROM film_category WHERE category_id IS NOT NULL)

  UNION ALL

  -- Recursive member: Join with the film_category and category tables
  SELECT fc.category_id, c.name, ch.category_id as parent_category_id, c.last_update
  FROM film_category fc
  JOIN CategoryHierarchy ch ON fc.film_id = ch.category_id
  JOIN category c ON fc.category_id = c.category_id
)

SELECT * FROM CategoryHierarchy;

-- 7)Create a CTE that combines information from the and tables to display the film title, language Name, and rental rate
WITH FilmLanguageInfo AS (
    SELECT
        f.film_id,
        f.title AS film_title,
        l.name AS language_name,
        f.rental_rate
    FROM
        film f
    JOIN
        language l ON f.language_id = l.language_id
)

SELECT
    film_id,
    film_title,
    language_name,
    rental_rate
FROM
    FilmLanguageInfo
ORDER BY
    film_id;


-- 8)Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from the customer and payment tables
WITH CustomerRevenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(p.amount) AS total_revenue
    FROM
        customer c
    LEFT JOIN
        payment p ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id, customer_name
)

SELECT
    customer_id,
    customer_name,
    total_revenue
FROM
    CustomerRevenue
ORDER BY
    customer_id;

-- 9) Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from the customer  and  parents tables
WITH CustomerRevenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(p.amount) AS total_revenue
    FROM
        customer c
    LEFT JOIN
        payment p ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id, customer_name
)

SELECT
    customer_id,
    customer_name,
    total_revenue
FROM
    CustomerRevenue
ORDER BY
    customer_id;

-- 10)Utilize a CTE with a window function to rank films based on their rental duration from the film table
WITH FilmRentalRank AS (
    SELECT
        film_id,
        title,
        rental_duration,
        RANK() OVER (ORDER BY rental_duration DESC) AS rental_rank
    FROM
        film
)

SELECT
    film_id,
    title,
    rental_duration,
    rental_rank
FROM
    FilmRentalRank
ORDER BY
    rental_rank;
    
-- 11)Create a CTE to list customers who have made more than two rentals, and then join this CTE with the customer table to retrieve additional customer details
WITH CustomersWithMoreThanTwoRentals AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(r.rental_id) AS rental_count
    FROM
        customer c
    LEFT JOIN
        rental r ON c.customer_id = r.customer_id
    GROUP BY
        c.customer_id, c.first_name, c.last_name
    HAVING
        COUNT(r.rental_id) > 2
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.address_id,
    c.active,
    -- Add other customer details as needed
    r.rental_count
FROM
    CustomersWithMoreThanTwoRentals r
JOIN
    customer c ON r.customer_id = c.customer_id;

-- 12)Write a query using a CTE to find the total number of rentals made each month, considering the rental_date from the rental table
WITH MonthlyRentals AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(rental_id) AS total_rentals
    FROM
        rental
    GROUP BY
        rental_month
)

SELECT
    rental_month,
    total_rentals
FROM
    MonthlyRentals
ORDER BY
    rental_month;
-- 13)Use a CTE to pivot the data from the  payment table to display the total payments made by each customer in separate columns for different payment methods
WITH PaymentPivot AS (
    SELECT
        p.customer_id,
        SUM(CASE WHEN p.staff_id IS NULL THEN p.amount ELSE 0 END) AS total_cash_payments,
        SUM(CASE WHEN p.staff_id IS NOT NULL THEN p.amount ELSE 0 END) AS total_credit_card_payments,
        -- Add more columns for other payment methods as needed
        SUM(p.amount) AS total_payments
    FROM
        payment p
    GROUP BY
        p.customer_id
)

SELECT
    pp.customer_id,
    c.first_name,
    c.last_name,
    pp.total_cash_payments,
    pp.total_credit_card_payments,
    -- Add more columns for other payment methods as needed
    pp.total_payments
FROM
    PaymentPivot pp
JOIN
    customer c ON pp.customer_id = c.customer_id;

-- 14)Create a CTE to generate a report showing pairs of actors who have appeared in the same film together, using the film_actor table
WITH ActorPairs AS (
    SELECT
        fa1.actor_id AS actor1_id,
        fa2.actor_id AS actor2_id,
        f.film_id,
        f.title AS film_title
    FROM
        film_actor fa1
    JOIN
        film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
    JOIN
        film f ON fa1.film_id = f.film_id
)

SELECT
    ap.actor1_id,
    a1.first_name AS actor1_first_name,
    a1.last_name AS actor1_last_name,
    ap.actor2_id,
    a2.first_name AS actor2_first_name,
    a2.last_name AS actor2_last_name,
    ap.film_id,
    ap.film_title
FROM
    ActorPairs ap
JOIN
    actor a1 ON ap.actor1_id = a1.actor_id
JOIN
    actor a2 ON ap.actor2_id = a2.actor_id
ORDER BY
    ap.film_id, ap.actor1_id, ap.actor2_id;

-- 15)Implement a recursive CTE to find all employees in the staff table who report to a specific manager, considering the reports_to column.
WITH RECURSIVE EmployeeHierarchy AS (
  SELECT last_name, staff_id, first_name, staff_id as manager_id, 0 as recursion_level
  FROM staff
  WHERE staff_id = 2 -- Specify the manager_id here

  UNION ALL

  SELECT s.last_name, s.staff_id, s.first_name, s.staff_id as manager_id, e.recursion_level + 1
  FROM staff s
  INNER JOIN EmployeeHierarchy e ON s.staff_id = e.manager_id
  WHERE e.recursion_level < 100  -- Limit recursion to 1000 levels (adjust as needed)
)

SELECT * FROM EmployeeHierarchy;