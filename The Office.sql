--creating 3 tables and inserting values into them

Create Table EmployeeDemographics 
(EmployeeID int, 
FirstName varchar(50), 
LastName varchar(50), 
Age int, 
Gender varchar(50)
)
 
Create Table EmployeeSalary 
(EmployeeID int, 
JobTitle varchar(50), 
Salary int
)
 
Insert into EmployeeDemographics VALUES
(1001, 'Jim', 'Halpert', 30, 'Male'),
(1002, 'Pam', 'Beasley', 30, 'Female'),
(1003, 'Dwight', 'Schrute', 29, 'Male'),
(1004, 'Angela', 'Martin', 31, 'Female'),
(1005, 'Toby', 'Flenderson', 32, 'Male'),
(1006, 'Michael', 'Scott', 35, 'Male'),
(1007, 'Meredith', 'Palmer', 32, 'Female'),
(1008, 'Stanley', 'Hudson', 38, 'Male'),
(1009, 'Kevin', 'Malone', 31, 'Male')
 
Insert Into EmployeeSalary VALUES
(1001, 'Salesman', 45000),
(1002, 'Receptionist', 36000),
(1003, 'Salesman', 63000),
(1004, 'Accountant', 47000),
(1005, 'HR', 50000),
(1006, 'Regional Manager', 65000),
(1007, 'Supplier Relations', 41000),
(1008, 'Salesman', 48000),
(1009, 'Accountant', 42000)
 
Insert into EmployeeDemographics VALUES
(1011, 'Ryan', 'Howard', 26, 'Male'),
(NULL, 'Holly','Flax', NULL, 'Male'),
(1013, 'Darryl', 'Philbin', NULL, 'Male')
 
Insert into EmployeeSalary VALUES
(1010, NULL, 47000),
(NULL, 'Salesman', 43000)
 
Insert into EmployeeDemographics VALUES
(1011, 'Ryan', 'Howard', 26, 'Male'),
(NULL, 'Holly','Flax', NULL, 'Male'),
(1013, 'Darryl', 'Philbin', NULL, 'Male')
 
Insert into EmployeeSalary VALUES
(1010, NULL, 47000),
(NULL, 'Salesman', 43000)
 
 
Create Table WareHouseEmployeeDemographics 
(EmployeeID int, 
FirstName varchar(50), 
LastName varchar(50), 
Age int, 
Gender varchar(50)
)
 
 
Insert into WareHouseEmployeeDemographics VALUES
(1013, 'Darryl', 'Philbin', NULL, 'Male'),
(1050, 'Roy', 'Anderson', 31, 'Male'),
(1051, 'Hidetoshi', 'Hasagawa', 40, 'Male'),
(1052, 'Val', 'Johnson', 31, 'Female')

-- show data of all employees with age greater than or equal to 30 in descending order
SELECT *
FROM EmployeeDemographics
WHERE Age>=30
ORDER BY Age DESC

-- show female employees with lastname starting with 'b'
SELECT FirstName,LastName,Gender
FROM EmployeeDemographics
WHERE LastName LIKE 'b%' AND Gender='Female'

-- 1 employee doesnt have their age in the dataset so lets update this
SELECT * FROM WareHouseEmployeeDemographics
WHERE Age IS NULL

--updating the age column to fill in missing value
UPDATE WareHouseEmployeeDemographics
SET Age=32
WHERE FirstName='Darryl'

--lets INNER join tables together to compare more data, we can simplify queries using alias'
SELECT *
FROM EmployeeDemographics d
JOIN EmployeeSalary s
ON d.employeeid=s.employeeid

--we have the employeeID column appearing twice, so lets get rid of one and store this procedure as a view so we can save time in writing long queries
CREATE VIEW emps AS
(SELECT d.EmployeeID,firstname,lastname,gender,JobTitle,age,salary
FROM EmployeeDemographics d
JOIN EmployeeSalary s
ON d.employeeid=s.employeeid)
-- view
SELECT *
FROM emps

--how many job roles have more than 1 person? this can be achieved using aggregate functions, GROUP BY and HAVING clauses
SELECT JobTitle,COUNT(Jobtitle) AS 'no. of workers'
FROM emps
GROUP BY JobTitle
HAVING COUNT(Jobtitle)>1

--however if we want to view the entire table using aggregate functions we can use PARTITION BY clauses
SELECT FirstName,LastName,JobTitle,COUNT(JobTitle) OVER (PARTITION BY JobTitle) AS 'no. of workers'
FROM emps
ORDER BY 'no. of workers' DESC

--using subqueries, the average salary across the office is 47461
(SELECT AVG(salary)
FROM EmployeeSalary)

--so we can see in this case that the people earning above average are all men
SELECT firstname,gender,salary,
(SELECT AVG(salary)FROM EmployeeSalary) as 'Avg Salary',
salary-(SELECT AVG(salary)FROM EmployeeSalary) AS 'Difference'
FROM emps

--on average men earn higher than women, 33% of both men and women earn higher than average in their respective gender groups
SELECT firstname,gender,salary, 
AVG(salary) OVER(PARTITION BY gender) AS 'Gender AVG Salary',
salary-AVG(salary) OVER(PARTITION BY gender) AS 'Difference'
FROM emps
Order BY 'Difference' DESC

--lets classofy each worker based on their salary using CASE/WHEN clauses
SELECT firstname,salary,(SELECT AVG(salary)FROM EmployeeSalary) as 'Avg Salary',
CASE
	WHEN salary>1.1*(SELECT AVG(salary) FROM EmployeeSalary) THEN 'Rich'
	WHEN salary>(SELECT AVG(salary) FROM EmployeeSalary) THEN 'Comfortable'
	WHEN salary>0.8*(SELECT AVG(salary) FROM EmployeeSalary) THEN 'Getting by'  
	ELSE 'Poor'
END AS 'Class'
FROM emps
ORDER BY 'salary' DESC