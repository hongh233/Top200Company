-- Query 1. SELECT from a single table with a WHERE clause, producing a derived attribute.
SELECT headquarters_city,
	   population,
       -- median_indeividual_income is yearly, devide 12 to get monthly
       ROUND(median_individual_income / 12) AS median_monthly_income,
       happiness_index
FROM City
WHERE happiness_index > 5.2;




-- Query 2. A NATURAL, INNER, or OUTER JOIN between two of your tables.
SELECT sector_name, innovation_level, average_profit_rate
FROM Sector INNER JOIN Industry USING(sector_name)
WHERE innovation_level = 'Moderate';




-- Query 3. A query covering one or more tables that uses a GROUP BY statement on at least one of your variables.
SELECT headquarters_city, COUNT(*) AS number_of_companies
FROM Company
GROUP BY headquarters_city
ORDER BY number_of_companies DESC
LIMIT 5;




-- Query 4: A query that makes use of at least one subquery in the FROM clause.
SELECT company_name, company_rank, industry_name, CEO.university_name AS CEO_graduate_university, headquarters_city, happiness_index
	-- un: companies where CEO graduate from top 5 universities with the highest number of CEO graduates
	FROM (SELECT university_name, COUNT(*) AS number_of_CEO
		  FROM CEO GROUP BY university_name
		  ORDER BY number_of_CEO DESC
		  LIMIT 5) un 
	INNER JOIN CEO ON un.university_name = CEO.university_name
    INNER JOIN Company USING(company_name)
    INNER JOIN City USING(headquarters_city)
    -- headquarters city has a happiness_index over the average level
    WHERE happiness_index > (SELECT AVG(happiness_index) FROM City)
    ORDER BY happiness_index DESC;




-- Query 5: A sequence of queries that:
			-- Creates a VIEW from two or more tables, including derived attributes
			-- Runs a SELECT query on the view
			-- Modifies one of the underlying tables
			-- Re-runs the SELECT query on the view, reflecting changes in the underlying tables and the derived attributes

-- Creates a VIEW from two tables, including number of CEOs a university have (CEO graduate)
CREATE VIEW top_5_university AS (
	SELECT university_name, COUNT(*) AS number_of_CEO
	FROM CEO GROUP BY university_name
    ORDER BY number_of_CEO DESC
    LIMIT 5);

-- Runs a SELECT query on the view
SELECT * FROM top_5_university;

-- Modifies the university which has highest number of CEO 
-- (We have already know its 'Harvard') to 'World University'
UPDATE CEO SET university_name = 'World University' 
	WHERE CEO_name <> 'A' AND university_name = 'Harvard University';
    
-- Re-runs the SELECT query on the view, the 'Harvard University' is changed to 'World University' 
SELECT * FROM top_5_university;




