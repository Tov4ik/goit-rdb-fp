CREATE SCHEMA pandemic;

USE pandemic;

DROP TABLE IF EXISTS infectious_cases_normalized;
DROP TABLE IF EXISTS countries;

CREATE TABLE countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(255),
    Code VARCHAR(10)
);

INSERT INTO countries (Entity, Code)
SELECT DISTINCT Entity, Code 
FROM infectious_cases;

CREATE TABLE infectious_cases_normalized (
    id INT AUTO_INCREMENT PRIMARY KEY,
    country_id INT,
    Year INT,
    Number_yaws DOUBLE,
    polio_cases DOUBLE,
    cases_guinea_worm DOUBLE,
    Number_rabies DOUBLE,
    Number_malaria DOUBLE,
    Number_hiv DOUBLE,
    Number_tuberculosis DOUBLE,
    Number_smallpox DOUBLE,
    Number_cholera_cases DOUBLE,
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

INSERT INTO infectious_cases_normalized (
    country_id, Year, Number_yaws, polio_cases, cases_guinea_worm, 
    Number_rabies, Number_malaria, Number_hiv, Number_tuberculosis, 
    Number_smallpox, Number_cholera_cases
)
SELECT 
    c.country_id, 
    ic.Year, 
    NULLIF(ic.Number_yaws, ''), 
    NULLIF(ic.polio_cases, ''), 
    NULLIF(ic.cases_guinea_worm, ''), 
    NULLIF(ic.Number_rabies, ''), 
    NULLIF(ic.Number_malaria, ''), 
    NULLIF(ic.Number_hiv, ''), 
    NULLIF(ic.Number_tuberculosis, ''), 
    NULLIF(ic.Number_smallpox, ''), 
    NULLIF(ic.Number_cholera_cases, '')
FROM infectious_cases ic
JOIN countries c ON ic.Entity = c.Entity AND (ic.Code = c.Code OR (ic.Code IS NULL AND c.Code IS NULL));


SELECT COUNT(*) FROM infectious_cases;
SELECT COUNT(*) FROM infectious_cases_normalized;



USE pandemic;

SELECT 
    c.Entity,
    c.Code,
    AVG(n.Number_rabies) AS average_rabies,
    MIN(n.Number_rabies) AS min_rabies,
    MAX(n.Number_rabies) AS max_rabies,
    SUM(n.Number_rabies) AS sum_rabies
FROM infectious_cases_normalized n
JOIN countries c ON n.country_id = c.country_id
WHERE n.Number_rabies IS NOT NULL 
GROUP BY c.Entity, c.Code
ORDER BY average_rabies DESC
LIMIT 10;



USE pandemic;

SELECT 
    Year,
    MAKEDATE(Year, 1) AS start_date,
    CURDATE() AS current_date_val,
    TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE()) AS years_difference
FROM infectious_cases
LIMIT 10;




USE pandemic;

DELIMITER //

CREATE FUNCTION calculate_year_diff(input_year INT)
RETURNS INT
DETERMINISTIC 
BEGIN
    DECLARE result INT;
    SET result = TIMESTAMPDIFF(YEAR, MAKEDATE(input_year, 1), CURDATE());
    RETURN result;
END //

DELIMITER ;

SELECT 
    Year,
    calculate_year_diff(Year) AS years_passed
FROM infectious_cases
LIMIT 10;







