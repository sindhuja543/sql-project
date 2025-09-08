CREATE TABLE IF NOT EXISTS covid_daily (
    country VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    confirmed INT DEFAULT 0,
    deaths INT DEFAULT 0,
    PRIMARY KEY (country, date)
);

-- Note: Import your CSV into 'covid_daily' before running queries.

 
SELECT 
    country, 
    MAX(confirmed) AS total_confirmed, 
    MAX(deaths) AS total_deaths
FROM covid_daily
GROUP BY country
ORDER BY total_confirmed DESC
LIMIT 10;

 
SELECT 
    date, 
    SUM(confirmed) AS total_confirmed, 
    SUM(deaths) AS total_deaths
FROM covid_daily
GROUP BY date
ORDER BY date;


SELECT 
    country, 
    date,
    confirmed - LAG(confirmed, 1, 0) OVER (PARTITION BY country ORDER BY date) AS new_cases
FROM covid_daily
ORDER BY country, date;

 
WITH daily_totals AS (
    SELECT 
        date, 
        SUM(confirmed) AS total_confirmed
    FROM covid_daily
    GROUP BY date
), new_cases AS (
    SELECT 
        date, 
        total_confirmed - LAG(total_confirmed, 1, 0) OVER (ORDER BY date) AS nc
    FROM daily_totals
)
SELECT 
    date, 
    nc AS new_cases,
    ROUND(
        AVG(nc) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),
        2
    ) AS ma7
FROM new_cases
ORDER BY date;