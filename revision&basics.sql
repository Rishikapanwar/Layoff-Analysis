-- BASICS RECAP 


SELECT * 
FROM parks_and_recreation.employee_demographics;


SELECT first_name, last_name, birth_date, age, (age+10)*10+1
FROM parks_and_recreation.employee_demographics;
#PEMDAS: paranthesis, exp, multiplication, division, add, sub

select * from employee_salary where salary<=50000;
select * from employee_demographics where birth_date> '1985-01-01';

select * from employee_demographics where birth_date> '1985-01-01' or not gender='male';

select * from employee_demographics where (first_name='Leslie' and age= 44) or age>55;

select * from employee_demographics where first_name LIKE 'Jer%'; #%- anything at the place of % (after)
select * from employee_demographics where first_name LIKE 'a__' ; # _ : number of underscores define how many characters come after a
select * from employee_demographics where first_name LIKE 'a___%'; # has 'a' , 3 characters after it and then anything after that, at least 3 chars after a
select * from employee_demographics where birth_date LIKE '1989%';

#GROUP BY: if the selected column is not an aggregated one, it has to be same as group by condition column (like here gender in both, otherwise avg or something else)
SELECT gender from employee_demographics group by gender;
select gender,avg(age) , max(age), min(age), count(age) from employee_demographics group by gender;

#ORDER BY: sorting 
select * from employee_demographics order by first_name;
select * from employee_demographics order by gender, age;
select * from employee_demographics order by 5,4;  #not recommended

-- HAVING VS WHERE
#select gender, avg(age) from employee_demographics where avg(age)>40 group by gender -> this doesnt work because grouping is not done yet in order to execute where clause, 
#in these cases, we use have (for cols other than group by col)
select gender, avg(age) from employee_demographics  group by gender having avg(age)>40;
SELECT occupation, AVG(salary) FROM employee_salary WHERE occupation LIKE '%manager%' GROUP BY occupation HAVING AVG(salary) > 75000;


-- Limit and aliasing
#LIMITS the displayed rows
SELECT * FROM employee_demographics ORDER BY age DESC LIMIT 3;
#Limit 2,1 -> start at row 2 and go till the specified number
SELECT * FROM employee_demographics ORDER BY age DESC LIMIT 2,3;

-- aliasing-> changing column names 
select gender, avg(age) as avg_age from employee_demographics  group by gender having avg_age>40;

-- JOIN -> combine columns together

select * from employee_demographics as dem 
inner join employee_salary as sal 
on dem.employee_id= sal.employee_id;

select dem.employee_id, age, salary from employee_demographics as dem 
inner join employee_salary as sal 
on dem.employee_id= sal.employee_id;
#inner join-> common rows in both tables
#left join-> everything from left table and only matched ones from right

select * from employee_demographics as dem 
right join employee_salary as sal 
on dem.employee_id= sal.employee_id;

-- SELF JOIN

select emp1.employee_id as emp_santa,
emp1.first_name as emp_firstname_santa,
emp1.last_name as emp_lastname_santa,
emp2.employee_id as emp_id,
emp2.first_name as emp2_firstname,
emp2.last_name as emp2_lastname
from employee_salary as emp1
join employee_salary as emp2
on emp1.employee_id+1= emp2.employee_id;


-- Joining multiple tables
select * from employee_demographics as dem 
inner join employee_salary as sal 
on dem.employee_id= sal.employee_id
inner join parks_departments as pd
on sal.dept_id = pd.department_id;


-- unions: combine rows together (unique values by default)
SELECT first_name, last_name
from employee_demographics
union 
select first_name, last_name
from employee_salary;

SELECT first_name, last_name
from employee_demographics
union all
select first_name, last_name
from employee_salary;

SELECT first_name, last_name, 'old man' as label
from employee_demographics where age >40 and gender='Male'
union 
SELECT first_name, last_name, 'old lady' as label
from employee_demographics where age >40 and gender='Female'
union
select first_name, last_name, 'highly paid' as label
from employee_salary where salary>70000
order by first_name, last_name;


-- string functions
# use case: in data cleaning, suppose to check phone numbers
SELECT first_name, length(first_name)
from employee_demographics 
order by 2;

SELECT UPPER('moments');
#helpful for standardisation of data

#trim: removes whitespaces
select trim('    moment    ');
select ltrim('   moment   ');
select rtrim('     moment   ');

select first_name,
LEFT(first_name,4),
RIGHT (first_name, 4)
from employee_demographics;

-- substrings in general are more useful: substring (col, start pos, no. of indices)
select first_name,
LEFT(first_name,4),
RIGHT (first_name, 4), birth_date,
substring(birth_date, 6,2) as birth_month
from employee_demographics;

-- replace(col, what needs to be replaced, new replaced letter/number)

select first_name, 
replace(first_name, 'a','z')  from employee_demographics ;

-- locate('what you're searching for', 'where you're searching for')->returns position
select locate('k','rishika');
SELECT LOCATE('An', first_name), first_name from employee_demographics;
-- concat (really useful in real scenarios)
select concat(first_name,' ', last_name) as full_name from employee_demographics;

-- case statements
select first_name, last_name , age,
CASE 
	when age <=30 then 'young'
    when age between 31 and 50 then 'old'
    when age>=50 then 'very old'
END as age_bracket
from employee_demographics;

-- pay increase and bonus
-- <50000=5%
-- >50000= 7%
-- if working with finance = 10% bonus
select * from employee_salary;
select first_name, last_name, salary, 
CASE
	when salary<50000 then salary+ (salary*0.05)
    when salary>=50000 then salary + (salary *0.07)
End as new_salary,
case
	when dept_id=6 then salary+ (salary*0.1)
END as new_bonus 
from employee_salary;


-- subqueries (needs to be 1 column only)
SELECT * 
FROM employee_demographics
WHERE employee_id IN ( SELECT employee_id 
						FROM employee_salary	
                        WHERE dept_id=1)
;

-- helpful in cases for aggregate functions -> if you need the overall avg salary, cant use avg(salary) without group by -> not useful

SELECT first_name, last_name, salary, (select avg(salary) from employee_salary) from employee_salary;
                        
select gender, avg(age), max(age), min(age), count(age) from employee_demographics group by gender;

-- helpful for aggregating already exisiting aggregate funcs
SELECT avg(`max(age)`) from
(select gender, avg(age), max(age), min(age), count(age) from employee_demographics group by gender) as agg_table;
 -- no need of backticks if you rename the cols
SELECT avg(max_age) from
(select gender, avg(age), max(age) as max_age, min(age), count(age) from employee_demographics group by gender) as agg_table;

-- WINDOW FUNCTIONS: useful when you need to use aggregate function info with other columns, allows you to add other cols without affecting the group by column for aggregate
SELECT gender, AVG(salary) OVER(partition by gender)
from employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id
;

-- can also be used for rolling totals:
SELECT dem.first_name, dem.last_name, dem.gender, salary, SUM(sal.salary) OVER (PARTITION BY dem.gender ORDER BY dem.employee_id ) as Rolling_total
FROM employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id= sal.employee_id;

-- can also be used for row numbers

SELECT dem.employee_id, dem.first_name, dem.last_name, dem.gender, salary, ROW_NUMBER() OVER (PARTITION BY dem.gender) as row_num
FROM employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id= sal.employee_id;

-- if you want to now order this based on salary:
SELECT dem.employee_id, dem.first_name, dem.last_name, dem.gender, salary, ROW_NUMBER() OVER (PARTITION BY dem.gender ORDER BY salary DESC) as row_num
FROM employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id= sal.employee_id;
-- If you have duplicates and want to give same rank-> use rank instead of row_num
SELECT dem.employee_id, dem.first_name, dem.last_name, dem.gender, salary, RANK() OVER (PARTITION BY dem.gender ORDER BY salary DESC) as rank_num
FROM employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id= sal.employee_id;

-- problem with rank: if there are duplicates-> the next higher value gets the number assigned positionally: use dense rank to solve this
SELECT dem.employee_id, dem.first_name, dem.last_name, dem.gender, salary, dense_rank() OVER (PARTITION BY dem.gender ORDER BY salary DESC) as dense_rank_num
FROM employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id= sal.employee_id;


-- cte: similar to subqueries: just simpler and cleaner representation
-- useful for aggregating on existing agg func cols
-- its not saved in memory, cant re-use it; it needs to be called immediately after creating it
WITH cte_example as
(select gender, avg(age) as avg_age, max(age) as max_age, min(age), count(age) from employee_demographics group by gender)
SELECT AVG(avg_age) from cte_example;

-- if there are a lot of functionalities for each table, its better to create cte instead of joining them
with cte1 as
(select employee_id, first_name, last_name, age from employee_demographics where age>30),
 cte2 as 
(select employee_id, salary from employee_salary where salary > 25000)
select * from cte1 join cte2 on cte1.employee_id= cte2.employee_id;

-- you can define the col names beforehand, overwrites the expressions in select query as well
WITH cte_example (GENDER, AVG_AGE, MAX_AGE, MIN_AGE, COUNT_AGE)as
(select gender, avg(age) as avg_age, max(age) as max_age, min(age), count(age) from employee_demographics group by gender)
SELECT * from cte_example;


-- TEMPORARY TABLES
CREATE TEMPORARY TABLE  temp_table
( first_name VARCHAR(50),
last_name VARCHAR(50),
age int);
INSERT INTO temp_table VALUES ('Rishika', 'Panwar', 22);
SELECT * 
FROM temp_table;

CREATE TEMPORARY TABLE  salary_over50k
SELECT * from employee_salary where salary>50000;
select * from salary_over50k;


-- stored procedures -> storing complex queries
SELECT * from employee_salary where salary>=50000;

CREATE PROCEDURE large_salaries()
SELECT * from employee_salary where salary>=50000;

CALL large_salaries();

-- if you want to use multiple statements in stored procedure:

DELIMITER $$
CREATE PROCEDURE new_procedure()
BEGIN
	SELECT * FROM employee_salary where salary>50000;
    SELECT * from employee_salary where salary>60000;
END $$
DELIMITER ;

CALL new_procedure();

-- these procedures are just like funcs in python: it can also use arguments
DELIMITER $$
CREATE PROCEDURE new_procedure1(given_employee_id INT)
BEGIN
	SELECT salary FROM employee_salary where employee_id= given_employee_id;
END $$
DELIMITER ;

CALL new_procedure1(1);

-- triggers and events
-- update people info automatically if one table is updated

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN 
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ;

INSERT INTO employee_salary VALUES(20, 'Rishika', 'Panwar', 'Intern', 20000, Null);
select * from employee_salary;
select * from employee_demographics;


-- events: scheduled 
DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
	DELETE  FROM employee_demographics 
    WHERE age>=60;
END $$
DELIMITER ;
SELECT * FROM employee_demographics;


-- how to check if its working or not: check if its on
SHOW VARIABLES LIKE 'event%';

-- if its off: go to edit-> preferences-> bottom: delete with no restrictions uncheck

