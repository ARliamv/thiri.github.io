USE employees;

# Check the database

SELECT COUNT(*) AS employee_count
FROM employees;

SELECT *
FROM employees
LIMIT 10;

SELECT COUNT(*) AS dept_emp_count
FROM dept_emp;

SELECT COUNT(*) AS manager_count
FROM dept_manager;

SELECT COUNT(*) AS title_count
FROM titles;

SELECT COUNT(*) AS salary_count
FROM salaries;


# Q1. Current department of each employee

SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    d.dept_name,
    de.from_date,
    de.to_date
FROM employees e
JOIN dept_emp de
    ON e.emp_no = de.emp_no
JOIN departments d
    ON de.dept_no = d.dept_no
WHERE de.to_date = '9999-01-01';


# Q2. Top 5 highest-paid employees by department and gender

WITH current_employee_salary AS (

    SELECT
        e.emp_no,
        e.first_name,
        e.last_name,
        e.gender,
        d.dept_name,
        s.salary
    FROM employees e
    JOIN dept_emp de
        ON e.emp_no = de.emp_no
    JOIN departments d
        ON de.dept_no = d.dept_no
    JOIN salaries s
        ON e.emp_no = s.emp_no
    WHERE de.to_date = '9999-01-01'
      AND s.to_date = '9999-01-01'
),

ranked_employees AS (

    SELECT
        *,
        RANK() OVER (
            PARTITION BY dept_name, gender
            ORDER BY salary DESC
        ) AS salary_rank,
        AVG(salary) OVER (
            PARTITION BY dept_name, gender
        ) AS average_salary
    FROM current_employee_salary
)

SELECT
    emp_no,
    first_name,
    last_name,
    gender,
    dept_name,
    salary,
    ROUND(average_salary, 2) AS average_salary,
    salary_rank
FROM ranked_employees
WHERE salary_rank <= 5
ORDER BY dept_name, gender, salary DESC;


# Q3. Departments with average salary above 70000

SELECT
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS average_salary
FROM departments d
JOIN dept_emp de
    ON d.dept_no = de.dept_no
JOIN salaries s
    ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
  AND s.to_date = '9999-01-01'
GROUP BY d.dept_name
HAVING AVG(s.salary) > 70000
ORDER BY average_salary DESC;


# Q4. Most common job title for each department

WITH title_counts AS (

    SELECT
        d.dept_no,
        d.dept_name,
        t.title,
        COUNT(*) AS title_count
    FROM departments d
    JOIN dept_emp de
        ON d.dept_no = de.dept_no
    JOIN titles t
        ON de.emp_no = t.emp_no
    WHERE de.to_date = '9999-01-01'
      AND t.to_date = '9999-01-01'
    GROUP BY
        d.dept_no,
        d.dept_name,
        t.title
),

ranked_titles AS (

    SELECT
        *,
        RANK() OVER (
            PARTITION BY dept_no
            ORDER BY title_count DESC
        ) AS title_rank
    FROM title_counts
)

SELECT
    dept_name,
    title,
    title_count
FROM ranked_titles
WHERE title_rank = 1
ORDER BY dept_name;


# Q5. Employees who changed departments more than once

SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    COUNT(de.dept_no) AS department_count
FROM employees e
JOIN dept_emp de
    ON e.emp_no = de.emp_no
GROUP BY
    e.emp_no,
    e.first_name,
    e.last_name
HAVING COUNT(de.dept_no) > 1
ORDER BY department_count DESC;


# Q6. Salary growth percentage

WITH salary_history AS (

    SELECT
        emp_no,
        salary,
        from_date,
        LAG(salary) OVER (
            PARTITION BY emp_no
            ORDER BY from_date
        ) AS previous_salary
    FROM salaries
)

SELECT
    emp_no,
    salary,
    previous_salary,
    ROUND(
        ((salary - previous_salary) / previous_salary) * 100,
        2
    ) AS salary_growth_percentage
FROM salary_history
WHERE previous_salary IS NOT NULL
ORDER BY emp_no, from_date
LIMIT 1000;


# Q7. Gender diversity by department

SELECT
    d.dept_name,
    SUM(
        CASE
            WHEN e.gender = 'M' THEN 1
            ELSE 0
        END
    ) AS male_count,
    SUM(
        CASE
            WHEN e.gender = 'F' THEN 1
            ELSE 0
        END
    ) AS female_count
FROM employees e
JOIN dept_emp de
    ON e.emp_no = de.emp_no
JOIN departments d
    ON de.dept_no = d.dept_no
WHERE de.to_date = '9999-01-01'
GROUP BY d.dept_name
ORDER BY d.dept_name;


# Q8. Average salary managed by each department manager

SELECT
    d.dept_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
    ROUND(AVG(s.salary), 2) AS average_managed_salary
FROM dept_manager dm
JOIN departments d
    ON dm.dept_no = d.dept_no
JOIN employees m
    ON dm.emp_no = m.emp_no
JOIN dept_emp de
    ON dm.dept_no = de.dept_no
JOIN salaries s
    ON de.emp_no = s.emp_no
WHERE dm.to_date = '9999-01-01'
  AND de.to_date = '9999-01-01'
  AND s.to_date = '9999-01-01'
GROUP BY
    d.dept_name,
    m.first_name,
    m.last_name
ORDER BY average_managed_salary DESC;


# Q9. Create a view

DROP VIEW IF EXISTS current_employee_salary;

CREATE VIEW current_employee_salary AS

SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    e.gender,
    d.dept_name,
    s.salary
FROM employees e
JOIN dept_emp de
    ON e.emp_no = de.emp_no
JOIN departments d
    ON de.dept_no = d.dept_no
JOIN salaries s
    ON e.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01'
  AND s.to_date = '9999-01-01';


# Test the view

SELECT *
FROM current_employee_salary
LIMIT 20;


# Create a stored procedure

DROP PROCEDURE IF EXISTS department_summary;

DELIMITER $$

CREATE PROCEDURE department_summary(
    IN p_department_name VARCHAR(40)
)

BEGIN

    SELECT
        dept_name,
        COUNT(*) AS employee_count,
        ROUND(AVG(salary), 2) AS average_salary,
        MIN(salary) AS minimum_salary,
        MAX(salary) AS maximum_salary
    FROM current_employee_salary
    WHERE dept_name = p_department_name
    GROUP BY dept_name;

END $$

DELIMITER ;


# Test the procedure

CALL department_summary('Finance');