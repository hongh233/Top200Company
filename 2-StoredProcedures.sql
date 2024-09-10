
-- First stored procedure: change headquarter city of a company
DELIMITER $$
DROP PROCEDURE IF EXISTS move_headquarters_city$$
CREATE PROCEDURE move_headquarters_city(
	IN company_name_var VARCHAR(50),			-- the company where we want to change the headquarter city
    IN new_headquarters_city VARCHAR(50),     	-- new city name
    IN new_city_population INT, 				-- new city population
    IN new_city_median_individual_income INT, 	-- new city median individual income
    IN new_city_happiness_index DECIMAL(5,2))	-- new city happiness index
BEGIN
	-- define a variable to store old headquarters_city
	DECLARE old_headquarters_city_var VARCHAR(50);
    
	START TRANSACTION;
    
    -- get headquarters_city value from Company table and assign it to variable old_headquarters_city
    SELECT headquarters_city INTO old_headquarters_city_var FROM Company
    WHERE Company.company_name = company_name_var;
    
    -- check if the provided company name exist, if exist, then continue execute, otherwise rollback
    IF old_headquarters_city_var IS NULL THEN
		SELECT "Can not find a old_headquarters_city from the provided company name!";
	ELSE
	
    -- Capture old values
    DROP TABLE IF EXISTS headquarters_city_change;
    CREATE TEMPORARY TABLE headquarters_city_change
		SELECT company_name, headquarters_city, population, median_individual_income, happiness_index, "Old"
			FROM Company INNER JOIN City USING(headquarters_city)
            WHERE Company.company_name = company_name_var;
    
    -- Insert a new City row, ignore if it already exist in City table
    INSERT IGNORE INTO City (headquarters_city, population, median_individual_income, happiness_index) VALUES
	(new_headquarters_city, new_city_population, new_city_median_individual_income, new_city_happiness_index);
    
    -- Update Company table with new headquarters city
	UPDATE Company
		SET headquarters_city = new_headquarters_city
        WHERE Company.company_name = company_name_var;
        
	-- Delete unused City row
	DELETE FROM City
		-- find headquarters_city in City table that is not be used by any company
		WHERE headquarters_city NOT IN (SELECT * FROM (SELECT headquarters_city FROM Company) hd)
        -- find the old headquarters_city in City table
		AND headquarters_city = old_headquarters_city_var;
        
	-- Capture new values
    INSERT INTO headquarters_city_change
		SELECT company_name, headquarters_city, population, median_individual_income, happiness_index, "New"
			FROM Company INNER JOIN City USING(headquarters_city)
            WHERE City.headquarters_city = new_headquarters_city;
            
	-- Check if the change will work
    SELECT * FROM headquarters_city_change;
    DROP TABLE headquarters_city_change;

	END IF;
	COMMIT;
END;
$$
DELIMITER ;


SET @company_name := "Walmart";						-- the company where we want to change the headquarter city
SET @headquarters_city := "Coventry, RI";			-- new city name
SET @population := 70482;							-- new city population
SET @median_individual_income := 51220;				-- new city median individual income
SET @happiness_index := 6.59;						-- new city happiness index
-- Change headquarter city of Walmart to Coventry,RI
CALL move_headquarters_city(@company_name, @headquarters_city, @population, 
                            @median_individual_income, @happiness_index);


SET @company_name := "Walmarj";						-- the error company name
SET @headquarters_city := "Coventry, RI";			-- new city name
SET @population := 70482;							-- new city population
SET @median_individual_income := 51220;				-- new city median individual income
SET @happiness_index := 6.59;						-- new city happiness index
-- test the error case
CALL move_headquarters_city(@company_name, @headquarters_city, @population, 
                            @median_individual_income, @happiness_index);


-- *****************************************************************************************
-- *************************************** FIRST END ***************************************
-- *****************************************************************************************


-- Second stored procedure: change CEO of a company
DELIMITER $$
DROP PROCEDURE IF EXISTS change_CEO$$
CREATE PROCEDURE change_CEO(
	IN old_CEO_name VARCHAR(50),     				-- the old CEO name
	IN new_CEO_name VARCHAR(50),					-- the new CEO name
    IN new_year_of_birth CHAR(4),					-- the new CEO information
    IN new_highest_degree VARCHAR(30),				-- the new CEO information
    IN new_university_name VARCHAR(100),			-- the new CEO information
    IN new_major_name VARCHAR(50),					-- the new CEO information
    IN new_CEO_is_female BOOLEAN,					-- the new CEO information
    IN new_founder_is_CEO BOOLEAN)					-- the CEO information related to Company table
BEGIN

	DECLARE old_CEO_exist INT;						-- a number determine whether the provided old CEO name exist
    DECLARE company_name_var VARCHAR(50);			-- the company involved by the old and new CEOs
	
	START TRANSACTION;
    
    -- find the company that managed by the old CEO, assign its name to the company_name_var
    SELECT CEO.company_name INTO company_name_var
		FROM CEO WHERE CEO.CEO_name = old_CEO_name;
        
	-- find if the old CEO is exist, 1 means exist, 0 means not exist, other means error
	SELECT COUNT(*) INTO old_CEO_exist  
		FROM CEO WHERE CEO.CEO_name = old_CEO_name;
        
    -- check if the old CEO is exist, only if exist we will update the CEO information 
	IF old_CEO_exist = 1 THEN
    
		-- Capture old values
		DROP TABLE IF EXISTS show_CEO_change;
		CREATE TEMPORARY TABLE show_CEO_change
			SELECT CEO_name, company_name, year_of_birth, highest_degree, 
			       university_name, major_name, CEO_is_female, founder_is_CEO, "Old"
			FROM Company INNER JOIN CEO USING(company_name)
            WHERE company_name = company_name_var;
    
		-- Update the CEO name and other information in CEO table
		UPDATE CEO
			SET CEO_name = new_CEO_name,
				year_of_birth = new_year_of_birth,
                highest_degree = new_highest_degree,
                university_name = new_university_name,
                major_name = new_major_name,
                CEO_is_female = new_CEO_is_female
			WHERE CEO_name = old_CEO_name;
            
		-- Update the CEO related information in Company table
		UPDATE Company
			SET founder_is_CEO = new_founder_is_CEO
            WHERE company_name = company_name_var;

		-- Capture new values
		INSERT INTO show_CEO_change
			SELECT CEO_name, company_name, year_of_birth, highest_degree, 
			       university_name, major_name, CEO_is_female, founder_is_CEO, "New"
			FROM Company INNER JOIN CEO USING(company_name) 
			WHERE CEO_name = new_CEO_name;
				
		-- Check if the change will work
		SELECT * FROM show_CEO_change;
		DROP TABLE show_CEO_change;
	
	ELSEIF old_CEO_exist = 0 THEN 
		SELECT "The old CEO name provided can not be found.";
    ELSE SELECT "Error! The amount of old_CEO_exist can't be other numebr!";
    END IF;

	COMMIT;
END;
$$
DELIMITER ;


SET @old_CEO_name := "Albert Bourla";	   					-- the old CEO name
SET @new_CEO_name := 'David O'' Halloran';					-- the new CEO name
SET @year_or_birth := 1973;									-- the new CEO birth year
SET @highest_degree := "Master";							-- the new CEO highest degree
SET @university_name :=	"Cornell University";				-- the new CEO graduate university name
SET @major_name :=	"Economics";							-- the new CEO degree major
SET @CEO_is_female := 0;									-- whether the new CEO is female
SET @founder_is_CEO := 0;									-- whether founder of the company is still CEO
-- Change CEO from Albert Bourla to David O' Halloran
CALL change_CEO(@old_CEO_name, @new_CEO_name, @year_or_birth, @highest_degree, 
                @university_name, @major_name, @CEO_is_female, @founder_is_CEO);


SET @old_CEO_name := "Wai Bi Ba Bo";	   					-- a wrong old CEO name (can't find in the table)
SET @new_CEO_name := 'David O'' Halloran';					-- the new CEO name
SET @year_or_birth := 1973;									-- the new CEO birth year
SET @highest_degree := "Master";							-- the new CEO highest degree
SET @university_name :=	"Cornell University";				-- the new CEO graduate university name
SET @major_name :=	"Economics";							-- the new CEO degree major
SET @CEO_is_female := 0;									-- whether the new CEO is female
SET @founder_is_CEO := 0;									-- whether founder of the company is still CEO
-- test the error case
CALL change_CEO(@old_CEO_name, @new_CEO_name, @year_or_birth, @highest_degree, 
                @university_name, @major_name, @CEO_is_female, @founder_is_CEO);
                

-- ******************************************************************************************
-- *************************************** SECOND END ***************************************
-- ******************************************************************************************