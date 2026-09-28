create database Project ;
use Project ;

select * from project.employee_dataset_4000;

-- 1 Problem: Retrieve all employee records where salary_inr is greater than 1,500,000.

SELECT * FROM project.employee_dataset_4000
where salary_inr > 1500000 ;

-- 2 Problem: Select employee_name, job_title, and company for all employees located in 'Pune'.

SELECT employee_name , job_title , company , location 
FROM project.employee_dataset_4000
where location = 'Pune' ;

-- 3 Problem: Display employees whose employment type is Full-Time.

select employee_name , job_title , employment_type , company 
from project.employee_dataset_4000
where employment_type = 'Full-Time' ;

-- 4 Problem: Find the **top 10 highest-paid employees** and display their `employee_name`, `company`, `department`, `job_title`, and `salary_inr`.  

SELECT employee_name , company , department , job_title , salary_inr
FROM project.employee_dataset_4000
ORDER BY salary_inr desc
LIMIT 10;

-- 5 Problem Statement: Write a query to calculate the average salary and average years of experience across each office location, ordered by the highest headcount.

    
-- 6 Problem: List all employees working in the "Data Analytics" department located in Pune.
    
SELECT employee_name, department, location FROM project.employee_dataset_4000
WHERE department = 'Data Analytics' AND location = 'Pune';

-- RENAME 
alter table project.employee_dataset_4000
rename column ï»¿employee_id to  employee_id ;

-- 7 Problem: Employees with experience > 10 years and performance rating ≤ 2

SELECT employee_id , employee_name , experience_years , performance_rating
FROM project.employee_dataset_4000
WHERE experience_years > 10 AND performance_rating <= 2;

select * from project.employee_dataset_4000;

-- 8 Problem: Write a query using WHERE + AND/OR to find employees who work in "IT" or "Data Analytics" department AND have experience_years greater than 8.
SELECT * FROM project.employee_dataset_4000
WHERE ( department = 'IT' OR department = 'Data Analytics' ) AND experience_years > 8 ;

-- 9 Problem: Find the average performance_rating for each company and location combination.

SELECT company , location , AVG(performance_rating) AS avg_performance_rating , COUNT(*) AS total_employees
FROM project.employee_dataset_4000
GROUP BY company, location
ORDER BY company ASC, avg_performance_rating DESC;

-- 10 Problem: Find the department with the highest average performance_rating (use AVG + GROUP BY + ORDER BY).
SELECT department , AVG(performance_rating) AS avg_performance_rating 
FROM project.employee_dataset_4000 
GROUP BY department
ORDER BY avg_performance_rating 
LIMIT 1 ;

-- 11 Problem: Using LIKE, find all employees whose job_title contains the word "Manager".
SELECT * FROM project.employee_dataset_4000
WHERE job_title LIKE '%Manager%';

-- 12 Problem: Find the highest and lowest salary_inr within each location, using MAX and MIN in the same query.
SELECT max(salary_inr) , min(salary_inr) , location 
FROM project.employee_dataset_4000 
GROUP BY location; 

-- 13 Problem: Find all employees whose salary_inr is greater than the average salary of the entire company (overall average, using a subquery in WHERE).
SELECT salary_inr  , employee_name , employee_id , company 
FROM project.employee_dataset_4000
WHERE salary_inr > (SELECT avg(salary_inr) FROM project.employee_dataset_4000  ) ;

-- 14 Problem: Find employees who are not in the location(s) where the average salary is below ₹8,00,000 (subquery with NOT IN).


SELECT employee_id , employee_name , location 
FROM project.employee_dataset_4000 
WHERE location NOT IN  ( SELECT location  FROM project.employee_dataset_4000  
GROUP BY location  HAVING AVG(salary_inr)< 800000) ;

-- 15 Problem: Using NTILE(), divide employees into 4 salary quartiles overall, then find the average experience_years within each quartile.

WITH SalaryQuartiles AS (
    SELECT 
        experience_years,
        NTILE(4) OVER (
            ORDER BY salary_inr ASC
        ) AS quartile
    FROM project.employee_dataset_4000
)
SELECT 
    quartile,
    ROUND(AVG(experience_years), 2) AS avg_experience_years
FROM SalaryQuartiles
GROUP BY quartile
ORDER BY quartile;


select * from project.employee_dataset_4000;

-- 16 Problem: Using CASE WHEN, create a new column labeling performance_rating as 'Excellent' (5), 'Good' (3–4), or 'Needs Improvement' (1–2).
SELECT employee_id , performance_rating ,
CASE 
WHEN performance_rating = 5 THEN 'EXCELLENT'
WHEN performance_rating IN (3,4) THEN 'GOOD'
WHEN performance_rating IN (1,2) THEN 'NEED IMPROVEMENT'
ELSE 'UNRATED'
END AS performance_category 
FROM project.employee_dataset_4000 ;

--  17 Problem: Find all departments where the average salary is greater than the overall average salary (subquery in HAVING).
SELECT avg(salary_inr) , department 
FROM project.employee_dataset_4000 
GROUP BY department 
HAVING avg(salary_inr) > ( SELECT avg(salary_inr) FROM project.employee_dataset_4000  );

-- 18 Problem: Add a foreign key constraint to Attendance_Leaves referencing Employees(employee_id).
-- Step 1: Change employee_id to VARCHAR(50) NOT NULL in the parent table
ALTER TABLE project.employee_dataset_4000 
MODIFY COLUMN employee_id VARCHAR(50) NOT NULL;

-- Step 2: Add the PRIMARY KEY to the parent table
ALTER TABLE project.employee_dataset_4000 
ADD CONSTRAINT pk_employees_employee_id PRIMARY KEY (employee_id);

-- Step 3: Change employee_id to VARCHAR(50) in the child table so types match exactly
ALTER TABLE attendance_leaves 
MODIFY COLUMN employee_id VARCHAR(50);


ALTER TABLE attendance_leaves
ADD CONSTRAINT FK_attendance_leaves_employeeID
FOREIGN KEY ( employee_id )
REFERENCES project.employee_dataset_4000 ( employee_id ) ;

-- Write an ALTER TABLE statement to add a foreign key constraint named fk_att_emp on the attendance_leaves table referencing employee_id in employee_dataset_4000, configuring it so that deleting an employee from the parent table automatically purges their attendance logs, but updating an employee ID cascades the change.
ALTER TABLE attendance_leaves 
ADD CONSTRAINT FK_attendance_leaves_employee_id 
FOREIGN KEY ( employee_id ) 
REFERENCES project.employee_dataset_4000 ( employee_id ) ;

-- Problem: Find all employees who earn more than the average salary of their own department, but less than the company-wide maximum salary.
SELECT emp.employee_name , emp.employee_id , emp.salary_inr , emp.department
FROM project.employee_dataset_4000 emp 
WHERE emp.salary_inr > ( SELECT AVG(d.salary_inr) FROM project.employee_dataset_4000 d
WHERE d.department = emp.department ) AND emp.salary_inr < ( SELECT max(salary_inr) FROM  project.employee_dataset_4000 ) ;

-- Problem:  List employees whose attendance_percentage is below the average attendance percentage across the entire company.
SELECT E.employee_id , E.employee_name , A.attendance_percentage 
FROM project.employee_dataset_4000 E
JOIN attendance_leaves A
on E.employee_id = A.employee_id 
where A.attendance_percentage < ( SELECT avg(attendance_percentage) from attendance_leaves ) ;

-- Problem: . List all employees who have never taken a "Rejected" leave (use NOT IN / NOT EXISTS with attendance_leaves).
SELECT E.employee_id , E.employee_name 
FROM project.employee_dataset_4000 E
WHERE NOT EXISTS ( SELECT * FROM attendance_leaves A 
WHERE E.employee_id = A.employee_id AND A.last_leave_status = 'Rejected' ) ;

-- Problem: Display department names where the average experience_years of employees is greater than the overall company average experience.
SELECT department, AVG(experience_years) AS avg_exp
FROM employee_dataset_4000
GROUP BY department
HAVING AVG(experience_years) > ( SELECT AVG(experience_years) FROM employee_dataset_4000 );

-- Problem:  Find employees who are promotion_eligible = 'Yes' but have years_in_current_role greater than the average years-in-role of all promotion-eligible employees
SELECT r.employee_id, r.job_title, r.years_in_current_role FROM roles_designation r
WHERE r.promotion_eligible = 'Yes'
AND r.years_in_current_role > ( SELECT AVG(years_in_current_role) FROM roles_designation
WHERE promotion_eligible = 'Yes');

-- Problem:  Find the department(s) with the maximum number of employees using department_established_year before 2015 (join + GROUP BY + subquery with MAX)
SELECT department_name, COUNT(*) AS emp_count FROM department
WHERE department_established_year < 2015
GROUP BY department_name
HAVING COUNT(*) = ( SELECT MAX(cnt) FROM ( SELECT COUNT(*) AS cnt
FROM department
WHERE department_established_year < 2015 GROUP BY department_name ) AS sub );

-- Problem:  Display employees who earn more than every employee in the "Finance" department (use > ALL).
SELECT employee_id, employee_name, department, salary_inr
FROM employee_dataset_4000
WHERE salary_inr > ALL ( SELECT salary_inr FROM employee_dataset_4000 WHERE department = 'Finance' );

-- Problem:  Find employees whose monthly_tax_deducted_inr is higher than the average tax deducted for their job_title (join employee_dataset_4000 with salary_payroll, then subquery)
SELECT e.employee_id, e.employee_name, e.job_title, s.monthly_tax_deducted_inr
FROM employee_dataset_4000 e
JOIN salary_payroll s
 ON e.employee_id = s.employee_id
WHERE s.monthly_tax_deducted_inr > ( SELECT AVG(s2.monthly_tax_deducted_inr) FROM employee_dataset_4000 e2
JOIN salary_payroll s2 ON e2.employee_id = s2.employee_id
WHERE e2.job_title = e.job_title );

-- Problem:  Find employees who are promotion_eligible = 'Yes' but have years_in_current_role greater than the average years-in-role of all promotion-eligible employees.
SELECT r.employee_id, r.job_title, r.years_in_current_role FROM roles_designation r
WHERE r.promotion_eligible = 'Yes'AND r.years_in_current_role > (
SELECT AVG(years_in_current_role) FROM roles_designation
WHERE promotion_eligible = 'Yes');

-- Problem:  Display employees who work in a location where the department_established_year is the earliest among all locations (correlated subquery on department)
SELECT e.employee_id, e.employee_name, d.location, d.department_established_year
FROM employee_dataset_4000 e
JOIN department d ON e.employee_id = d.employee_id
WHERE d.department_established_year = ( SELECT MIN(d2.department_established_year)FROM department d2
WHERE d2.location = d.location );

-- Problem: Find employees whose salary_inr falls between the minimum and maximum salary of employees having the same education level, but excluding employees exactly at the min/max (subquery with BETWEEN)
SELECT e.employee_id, e.employee_name, e.education, e.salary_inr
FROM employee_dataset_4000 e
WHERE e.salary_inr > ( SELECT MIN(e2.salary_inr) FROM employee_dataset_4000 e2
WHERE e2.education = e.education )
AND e.salary_inr < ( SELECT MAX(e2.salary_inr) FROM employee_dataset_4000 e2
WHERE e2.education = e.education );

-- Problem:  Find employees who exist in roles_designation but do NOT have a corresponding leave record with last_leave_status = 'Approved' (use NOT EXISTS).
SELECT r.employee_id, r.job_title
FROM roles_designation r
WHERE NOT EXISTS ( SELECT * FROM attendance_leaves a
WHERE a.employee_id = r.employee_id AND a.last_leave_status = 'Approved');


SELECT * FROM project.employee_dataset_4000 ;
select * from attendance_leaves ;
SELECT *   FROM department  ; 
select * from salary_payroll;

SELECT * FROM roles_designation ;

select * from employees ;
drop table employees;

show tables ;



