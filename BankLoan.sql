CREATE TABLE dbo.financial_loan_raw (
    id                    INT,
    address_state         CHAR(2),
    application_type      VARCHAR(20),
    emp_length            VARCHAR(20),
    emp_title             NVARCHAR(200),
    grade                 CHAR(1),
    home_ownership        VARCHAR(20),
    issue_date            VARCHAR(10),
    last_credit_pull_date VARCHAR(10),
    last_payment_date     VARCHAR(10),
    loan_status           VARCHAR(20),
    next_payment_date     VARCHAR(10),
    member_id             INT,
    purpose               VARCHAR(50),
    sub_grade             CHAR(2),
    term                  VARCHAR(20),
    verification_status   VARCHAR(30),
    annual_income         DECIMAL(12,2),
    dti                   DECIMAL(6,4),
    installment           DECIMAL(8,2),
    int_rate              DECIMAL(6,4),
    loan_amount           INT,
    total_acc             INT,
    total_payment         INT
);

SELECT @@SERVERNAME;

SELECT * FROM bankloan.dbo.financial_loan_raw;  -- expect 38576

-- Created by GitHub Copilot in SSMS - review carefully before executing
-- Adds a new column and converts 'issue_date' (string) to a proper DATE in 'con_issue_date'

ALTER TABLE bankloan.dbo.financial_loan_raw
ADD con_issue_date DATE;

UPDATE bankloan.dbo.financial_loan_raw
SET con_issue_date = 
    CASE
        WHEN issue_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, issue_date, 103) -- DD/MM/YYYY
        WHEN issue_date LIKE '__-__-____' THEN TRY_CONVERT(DATE, issue_date, 105) -- DD-MM-YYYY
        WHEN issue_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, issue_date, 23) -- DD-MM-YYYY
        ELSE NULL
    END;

ALTER TABLE bankloan.dbo.financial_loan_raw
DROP COLUMN issue_date;



--SELECT DB_NAME();
--SELECT name
--FROM bankloan.sys.columns
--WHERE object_id = OBJECT_ID('bankloan.dbo.financial_loan_raw');


USE bankloan;
GO
EXEC sp_rename 'dbo.financial_loan_raw.con_issue_date', 'issue_date', 'COLUMN';

-- changing 'last_credit_pull_date' date type
ALTER TABLE bankloan.dbo.financial_loan_raw
ADD con_last_credit_pull_date DATE;

UPDATE bankloan.dbo.financial_loan_raw
SET con_last_credit_pull_date = 
    CASE
        WHEN last_credit_pull_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, last_credit_pull_date, 103) -- DD/MM/YYYY
        WHEN last_credit_pull_date LIKE '__-__-____' THEN TRY_CONVERT(DATE, last_credit_pull_date, 105) -- DD-MM-YYYY
        WHEN last_credit_pull_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, last_credit_pull_date, 23) -- DD-MM-YYYY
        ELSE NULL
    END;

ALTER TABLE bankloan.dbo.financial_loan_raw
DROP COLUMN last_credit_pull_date;

USE bankloan;
GO
EXEC sp_rename 'dbo.financial_loan_raw.con_last_credit_pull_date', 'last_credit_pull_date', 'COLUMN';

-- changing 'next_payment_date' date type
ALTER TABLE bankloan.dbo.financial_loan_raw
ADD con_next_payment_date DATE;

UPDATE bankloan.dbo.financial_loan_raw
SET con_next_payment_date = 
    CASE
        WHEN next_payment_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, next_payment_date, 103) -- DD/MM/YYYY
        WHEN  next_payment_date LIKE '__-__-____' THEN TRY_CONVERT(DATE, next_payment_date, 105) -- DD-MM-YYYY
        WHEN next_payment_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, next_payment_date, 23) -- DD-MM-YYYY
        ELSE NULL
    END;

ALTER TABLE bankloan.dbo.financial_loan_raw
DROP COLUMN next_payment_date;

USE bankloan;
GO
EXEC sp_rename 'dbo.financial_loan_raw.con_next_payment_date', 'next_payment_date', 'COLUMN';

-- changing 'last_payment_date' date type
ALTER TABLE bankloan.dbo.financial_loan_raw
ADD con_last_payment_date DATE;

UPDATE bankloan.dbo.financial_loan_raw
SET con_last_payment_date = 
    CASE
        WHEN last_payment_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, last_payment_date, 103) -- DD/MM/YYYY
        WHEN  last_payment_date LIKE '__-__-____' THEN TRY_CONVERT(DATE, last_payment_date, 105) -- DD-MM-YYYY
        WHEN last_payment_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, last_payment_date, 23) -- DD-MM-YYYY
        ELSE NULL
    END;

ALTER TABLE bankloan.dbo.financial_loan_raw
DROP COLUMN last_payment_date;

USE bankloan;
GO
EXEC sp_rename 'dbo.financial_loan_raw.con_last_payment_date', 'last_payment_date', 'COLUMN';


--cal. the total application received
select count(id) as Total_Loan_Applications
from bankloan.dbo.financial_loan_raw

-- cal month-to-date total loan application
select count(id) as MTD_Total_Loan_application
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 12 and Year(issue_date) = 2021; --4314

-- cal prev. month-to-date total loan application
select count(id) as PMTD_Total_Loan_application
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 11 and Year(issue_date) = 2021; --4035

-- cal the month-over-month MOM total loan applications
WITH MTD_app as(

select count(id) as MTD_Total_Loan_application
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 12 and Year(issue_date) = 2021),
PMTD_app AS (
select count(id) as PMTD_Total_Loan_application
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 11 and Year(issue_date) = 2021)

select (MTD.MTD_Total_Loan_application - PMTD.PMTD_Total_Loan_application)* 100.00 /PMTD.PMTD_Total_Loan_application
as MOM_Total_loan_application from MTD_app MTD, PMTD_app PMTD



-- cal the total funded amount
select sum(loan_amount) as Total_funded_amount
from bankloan.dbo.financial_loan_raw; -- 435757075

-- cal the MTD total funded amount
select sum(loan_amount) as MTD_Total_funded_amount
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 12 and Year(issue_date) = 2021; --53981425

-- cal the PMTD total funded amount
select sum(loan_amount) as PMTD_Total_funded_amount
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 11 and Year(issue_date) = 2021; --47754825
-- cal the month-over-month total amount funded
with MTD_funded as (
select sum(loan_amount) as MTD_Total_funded_amount
from bankloan.dbo.financial_loan_raw
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_funded as(select sum(loan_amount) as PMTD_Total_funded_amount
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 11 and Year(issue_date) = 2021)

select (MTD.MTD_Total_funded_amount - PMTD.PMTD_Total_funded_amount)* 100.00 /PMTD.PMTD_Total_funded_amount
as MOM_Total_funded_amount from MTD_funded MTD, PMTD_funded PMTD


-- cal total amount recieved

select sum(total_payment) as Total_amount_received
from bankloan.dbo.financial_loan_raw; -- 473070933

-- cal the MTD total amount received
select sum(total_payment) as MTD_Total_amount_received
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 12 and Year(issue_date) = 2021; --58074380

-- cal the PMTD total amount received
select sum(total_payment) as PMTD_Total_amount_received
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 11 and Year(issue_date) = 2021; --50132030

-- cal the month-over-month total amount received
with MTD_payment as (
select sum(total_payment) as MTD_Total_amount_received
from bankloan.dbo.financial_loan_raw
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_payment as(select sum(total_payment) as PMTD_Total_amount_received
from bankloan.dbo.financial_loan_raw 
where Month(issue_date) = 11 and Year(issue_date) = 2021)

select (MTD.MTD_Total_amount_received - PMTD.PMTD_Total_amount_received)* 100.00 /PMTD.PMTD_Total_amount_received
as MOM_Total_amount_funded from MTD_payment MTD, PMTD_payment PMTD
