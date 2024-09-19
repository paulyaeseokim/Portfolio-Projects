SELECT * FROM bank_loan_data

--DASHBOARD 1: SUMMARY
--1. Total Loan Applications
SELECT COUNT(id) AS Total_Loan_Applications FROM bank_loan_data

SELECT COUNT(id) AS MTD_Total_Loan_Applications FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021

SELECT COUNT(id) AS PMTD_Total_Loan_Applications FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021

--2. Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data

SELECT SUM(loan_amount) AS MTD_Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021

SELECT SUM(loan_amount) AS PMTD_Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021

--3. Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Received FROM bank_loan_data

SELECT SUM(total_payment) AS MTD_Total_Amount_Received FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021

SELECT SUM(total_payment) AS PMTD_Total_Amount_Received FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021

--4. Average Interest Rate
SELECT ROUND(AVG(int_rate), 4) * 100 AS Average_Interest_Rate FROM bank_loan_data

SELECT ROUND(AVG(int_rate), 4) * 100 AS MTD_Average_Interest_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021

SELECT ROUND(AVG(int_rate), 4) * 100 AS PMTD_Average_Interest_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021

--5. Average Debt-to-Income Ratio (DTI)
SELECT ROUND(AVG(dti), 4) * 100 AS Average_DTI FROM bank_loan_data

SELECT ROUND(AVG(dti), 4) * 100 AS MTD_Average_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021

SELECT ROUND(AVG(dti), 4) * 100 AS PMTD_Average_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021

--------------------------------
SELECT loan_status FROM bank_loan_data

--Good Loan vs. Bad Loan KPI's

--Good Loan KPI's
--1. Good Loan Application Percentage
SELECT 
	(COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END)) * 100
	/
	COUNT(id) AS Good_Loan_Percentage 
FROM bank_loan_data

--2. Good Loan Applications
SELECT COUNT(id) AS Good_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'

--3. Good Loan Funded Amount
SELECT SUM(loan_amount) AS Good_Loan_Funded_Amount FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'

--4. Good Loan Total Received Amount
SELECT SUM(total_payment) AS Good_Loan_Total_Amount_Received FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'

--Bad Loan KPI's
--1. Bad Loan Application Percentage
SELECT 
	(COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END)) * 100
	/
	COUNT(id) AS Bad_Loan_Percentage 
FROM bank_loan_data

--2. Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Charged Off'

--3. Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded_Amount FROM bank_loan_data
WHERE loan_status = 'Charged Off'

--4. Bad Loan Total Received Amount
SELECT SUM(total_payment) AS Bad_Loan_Total_Amount_Received FROM bank_loan_data
WHERE loan_status = 'Charged Off'

--Loan Status Grid View

SELECT
		loan_status,
		COUNT(id) AS Total_Loan_Applications,
		SUM(total_payment) AS Total_Amount_Received,
		SUM(loan_amount) AS Total_Funded_Amount,
		AVG(int_rate * 100) AS Interest_rate,
		AVG(dti * 100) AS DTI
	FROM 
		bank_loan_data
	GROUP BY
		loan_status

SELECT
		loan_status,
		SUM(total_payment) AS MTD_Total_Amount_Received,
		SUM(loan_amount) AS MTD_Total_Funded_Amount
	FROM 
		bank_loan_data
	WHERE
		MONTH(issue_date) = 12
	GROUP BY
		loan_status

--DASHBOARD 2: OVERVIEW
--1. Monthly Trends by Issue Date (Line Chart)
SELECT
	MONTH(issue_date) AS Month_Number,
	DATENAME(MONTH, issue_date) AS Month_Name, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM bank_loan_data
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date)

--2.Regional Analysis By State (Filled Map)
SELECT
	address_state,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM bank_loan_data
GROUP BY address_state
ORDER BY address_state

--3. Loan Term Analysis (Donut Chart)
SELECT
	term,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM bank_loan_data
GROUP BY term
ORDER BY term

--4. Employee Length Analysis (Bar Chart)
SELECT
	emp_length,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM bank_loan_data
GROUP BY emp_length
ORDER BY emp_length

--5. Loan Purpose Breakdown (Bar Chart)
SELECT
	purpose,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM bank_loan_data
GROUP BY purpose
ORDER BY purpose

--6. Home Ownership Analysis (Tree Map)
SELECT
	home_ownership,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM bank_loan_data
GROUP BY home_ownership
ORDER BY home_ownership

--DASHBOARD 3: DETAILS
SELECT * FROM bank_loan_data