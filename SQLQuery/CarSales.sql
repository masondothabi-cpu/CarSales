---Question to answer
-------------------------------------------------
---1. Which car and model makes more revenue
---2. Relation between price, mileage and Year of Make
---2.2 High mileage = high price, low mileage = low price, price drops if year is ----older
---3. Caltulate profit margin = (selling_price - cost_price) / selling_price * 100 NB: cost_price is not given
---3. Highest sale volume(region)
---4. Emerging trends in customer purchasing preferences
---5. Recommendation 

----------------------------------------------------------
---CHECKING AND UPDATING NULL VALUE
----------------------------------------------------------

SELECT * FROM CarSales;

---------------------------------------------------------
---DISCOVERING YEAR PERIOD OF THE CARS
---------------------------------------------------------
---STARTING YEAR MODEL 1982
---ENDING YEAR MODEL 2015

SELECT MIN (year) AS Start_year_Period FROM CarSales;
 
SELECT MAX(year) AS End_Year_Period FROM CarSales;


UPDATE CarSales
SET 
    year         = COALESCE(year, 0000),
    make         = COALESCE(make, 'F-000 Unkown'),
    model        = COALESCE(model, '1Unknown'),
    trim         = COALESCE(trim, 'Standard'),
    body         = COALESCE(body, 'Unknown'),
    transmission = COALESCE(transmission, 'Unknown'),
    state        = COALESCE(state, 'NA'),
    vin          = COALESCE (vin, '1unknown18vin7153'),
    condition    = COALESCE(condition, '00'),
    odometer     = COALESCE(odometer, 000000),
    color        = COALESCE(color, 'Unknown'),
    interior     = COALESCE(interior, 'Unknown'),
    seller       = COALESCE(seller, 'Unknown'),
    mmr          = COALESCE(mmr, 000000),
    sellingprice = COALESCE(sellingprice, 0.0000),
    saledate     = COALESCE(saledate, 'unk unk 00 0000 HH:mm:ss')
WHERE 
    year IS NULL OR
    make IS NULL OR
    model IS NULL OR
    trim IS NULL OR
    body IS NULL OR
    transmission IS NULL OR
    state IS NULL OR
    condition IS NULL OR
    odometer IS NULL OR
    color IS NULL OR
    interior IS NULL OR
    seller IS NULL OR
    mmr IS NULL OR
    sellingprice IS NULL OR
    saledate IS NULL;

    -----------------------------------------------------
    ---CHECKING IF UPDATES WERE SUCCESSFUL
    -----------------------------------------------------

SELECT * FROM CarSales
WHERE 
    year IS NULL OR
    make IS NULL OR
    model IS NULL OR
    trim IS NULL OR
    body IS NULL OR
    transmission IS NULL OR
    state IS NULL OR
    condition IS NULL OR
    odometer IS NULL OR
    color IS NULL OR
    interior IS NULL OR
    seller IS NULL OR
    mmr IS NULL OR
    sellingprice IS NULL OR
    saledate IS NULL;

---------------------------------------------------------------------------------
----CHECKING WHICH CAR MAKES MORE REVENUE\ SALES
----------------------------------------------------------------------------------
   SELECT 
    DISTINCT make,
    model,
    seller,
    SUM(sellingprice) AS total_revenue
FROM CarSales
GROUP BY make, model,seller 
ORDER BY total_revenue DESC;


---------------------------------------------------------------------------------
---CHECKING REL BETWEEN MILEAGE, PRICE AND YEAR
---------------------------------------------------------------------------------
SELECT year, 
    model, 
    make, 
    condition,
    AVG(odometer) AS average_mileage,
    AVG(sellingprice) AS average_price
FROM CarSales
GROUP BY year, model, make, condition
ORDER BY year;


-----------------------------------------------------------------------
---CHECKING HOW OLD THE CARS ARE. CHECKING THE OLDEST CAR 
---NEWEST = 11 years
---old = 44
-----------------------------------------------------------------------
SELECT year,
    (YEAR(CURRENT_DATE()) - `year`) AS car_age,
    --GROUP BY year, make, model,
---ORDER BY year

CASE 
        WHEN (YEAR(CURRENT_DATE()) - `year`) <= 5 THEN 'New Car'
        WHEN (YEAR(CURRENT_DATE()) - `year`) <= 15 THEN 'Mid Age'
        ELSE 'Old Car'
    END AS car_type

FROM CarSales;

---WHERE `year` > 0 
---ORDER BY car_age DESC
---LIMIT 1;

SELECT * FROM CarSales;


----------------------------------------------------------------
---CHECKING HOW MUCH SALES WERE MADE IN A PARTICULAR DAY/ MONTH
----------------------------------------------------------------
---1. Separate date and time of sale
---2. Filtering sales per day
SELECT * FROM CarSales;

SELECT 
year,
    make,
    model,
    saledate,
    TO_DATE(ts) AS sale_date,
    DATE_FORMAT(ts, 'HH:mm:ss') AS sale_time
FROM (
    SELECT 
        year,
        make,
        model,
        ---sellingprice,
        saledate,
        TRY_TO_TIMESTAMP(
            REGEXP_REPLACE(saledate, '^[A-Za-z]{3} ', ''),
            'MMM dd yyyy HH:mm:ss'
        ) AS ts
    FROM CarSales
) t

---GROUP BY saledate AS sales_made ;
SELECT 
    saledate AS sales_made,
    seller,
    COUNT(*) AS total_sales,
    SUM(sellingprice) AS total_amount_made
FROM CarSales
GROUP BY saledate, seller
ORDER BY total_amount_made DESC;

---------------------------------------------
---ONE Query
---------------------------------------------

UPDATE CarSales
SET 
    year         = COALESCE(year, 0),
    make         = COALESCE(make, 'F-000 Unknown'),
    model        = COALESCE(model, '1Unknown'),
    trim         = COALESCE(trim, 'Standard'),
    body         = COALESCE(body, 'Unknown'),
    transmission = COALESCE(transmission, 'Unknown'),
    state        = COALESCE(state, 'NA'),
    vin          = COALESCE(vin, '1unknown18vin7153'),
    condition    = COALESCE(condition, '00'),
    odometer     = COALESCE(odometer, 0),
    color        = COALESCE(color, 'Unknown'),
    interior     = COALESCE(interior, 'Unknown'),
    seller       = COALESCE(seller, 'Unknown'),
    mmr          = COALESCE(mmr, 0),
    sellingprice = COALESCE(sellingprice, 0),
    saledate     = COALESCE(saledate, 'Jan 01 2000 00:00:00')
WHERE 
    year IS NULL OR make IS NULL OR model IS NULL OR
    trim IS NULL OR body IS NULL OR transmission IS NULL OR
    state IS NULL OR condition IS NULL OR odometer IS NULL OR
    color IS NULL OR interior IS NULL OR seller IS NULL OR
    mmr IS NULL OR sellingprice IS NULL OR saledate IS NULL;

    WITH cleaned AS (
    SELECT 
        year,
        make,
        model,
        seller,
        sellingprice,
        saledate,

        TRY_TO_TIMESTAMP(
            REGEXP_REPLACE(saledate, '^[A-Za-z]{3} ', ''),
            'MMM dd yyyy HH:mm:ss'
        ) AS ts,

        (YEAR(CURRENT_DATE()) - year) AS car_age,

        CASE 
            WHEN (YEAR(CURRENT_DATE()) - year) <= 5 THEN 'New Car'
            WHEN (YEAR(CURRENT_DATE()) - year) <= 15 THEN 'Mid Age'
            ELSE 'Old Car'
        END AS car_type

    FROM CarSales
    WHERE year > 0
)

SELECT 
    make,
    model,
    car_type,

    DATE(ts) AS sale_date,
    DATE_FORMAT(ts, 'HH:mm:ss') AS sale_time,

    DAYNAME(ts) AS day_name,
    MONTHNAME(ts) AS month_name,
    DAYOFMONTH(ts) AS day_of_month,

    COUNT(*) AS total_cars,
    SUM(sellingprice) AS total_revenue,
    AVG(sellingprice) AS avg_price

FROM cleaned
GROUP BY 
    make,
    model,
    car_type,
    seller,
    DATE(ts),
    DATE_FORMAT(ts, 'HH:mm:ss'),
    DAYNAME(ts),
    MONTHNAME(ts),
    DAYOFMONTH(ts)

ORDER BY total_revenue DESC;
