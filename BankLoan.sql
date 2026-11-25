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

-- cal the avg int rate
select AVG(int_rate)*100 AS Avg_interest_rate from bankloan.dbo.financial_loan_raw

-- cal the MTD avg Int rate
 select AVG(int_rate)*100 AS MTD_Avg_interest_rate from bankloan.dbo.financial_loan_raw
where month(issue_date)= 12 and Year(issue_date) =2021

--cal the pmtd avg int rate

 select AVG(int_rate)*100 AS PMTD_Avg_interest_rate from bankloan.dbo.financial_loan_raw
where month(issue_date)= 11 and Year(issue_date) =2021


-- cal the month-over-month Avg int rate
with MTD_avg_int as (
select AVG(int_rate)*100 AS MTD_Avg_interest_rate from bankloan.dbo.financial_loan_raw
where month(issue_date)= 12 and Year(issue_date) =2021)
,
PMTD_avg_int as(
select AVG(int_rate)*100 AS PMTD_Avg_interest_rate from bankloan.dbo.financial_loan_raw
where month(issue_date)= 11 and Year(issue_date) =2021)


select (MTD.MTD_Avg_interest_rate - PMTD.PMTD_Avg_interest_rate)* 100.00 /PMTD.PMTD_Avg_interest_rate
as MOM_Avg_interest_rate from MTD_avg_int MTD, PMTD_avg_int PMTD


-- cal the avg debt to income ratio(DTI)

select avg(dti) *100 as MTD_Avg_DTI from bankloan.dbo.financial_loan_raw

-- cal the MTD dti
select avg(dti) *100 as MTD_Avg_DTI from bankloan.dbo.financial_loan_raw
where month(issue_date)= 12 and Year(issue_date) =2021
-- cal the PMTD dti
select avg(dti) *100 as PMTD_Avg_DTI from bankloan.dbo.financial_loan_raw
where month(issue_date)= 11 and Year(issue_date) =2021

-- cal the month-over-month total amount received
with MTD_DTI as (
select avg(dti) *100 as MTD_Avg_DTI
from bankloan.dbo.financial_loan_raw
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_DTI as(select avg(dti) *100 as PMTD_Avg_DTI
from bankloan.dbo.financial_loan_raw
where month(issue_date) = 11 and year(issue_date) = 2021)

select (MTD.MTD_Avg_DTI - PMTD.PMTD_Avg_DTI)* 100.00 /PMTD.PMTD_Avg_DTI
as MOM_Avg_DTI from MTD_DTI MTD, PMTD_DTI PMTD

--cal the Good loan application percentage
select (count(case when loan_status = 'Fully Paid' or loan_status = 'Current' then id END)*100)/count(id)
as Good_loan_percentage 
from bankloan.dbo.financial_loan_raw

--cal the totaol good loan applocation
select count(id)
as Good_loan_application
from bankloan.dbo.financial_loan_raw
where loan_status= 'Fully Paid' or loan_status='Current'

-- cal the good loan percentage fund
select sum(loan_amount)
as Good_loan_Funded_Amount
from bankloan.dbo.financial_loan_raw
where loan_status= 'Fully Paid' or loan_status='Current'

-- cal the good loan percentage receive
select sum(total_payment)
as Good_loan_Amount_Received
from bankloan.dbo.financial_loan_raw
where loan_status= 'Fully Paid' or loan_status='Current'

--bad loan

--cal the bad loan application percentage
select (count(case when loan_status = 'Charged Off' then id END)*100.0)/count(id)
as Bad_loan_percentage 
from bankloan.dbo.financial_loan_raw

--cal the totaol good loan applocation
select count(id)
as Bad_loan_application
from bankloan.dbo.financial_loan_raw
where loan_status= 'Charged Off'

--cal the Bad loan funded amount
select sum(loan_amount)
as Bad_loan_funded_amount
from bankloan.dbo.financial_loan_raw
where loan_status= 'Charged Off'

--cal the loan count, total amount receieved, total funded amount, int rate. DTi
-- on the basis of the loan status
select
loan_status,
count(id) as Loan_Count,
sum(total_payment) as Total_Amount_Received,
sum(loan_amount) as Total_Funded_Amount,
avg(int_rate * 100) as Interest_Rate,
Avg(dti * 100) as DTI
from bankloan.dbo.financial_loan_raw
Group by loan_status

-- cal MTD_total_amount_received, MTD_total_funded_amount on the base of loan_status
select
loan_status,
sum(total_payment) as MTD_Total_Amount_Received,
sum(loan_amount) as MTD_Total_funded_amount
from
bankloan.dbo.financial_loan_raw
where month(issue_date) = 12  and year(issue_date) = 2021
group by loan_status

-- cal monthly total_loan application, total_funded_amount and Total_amount_received
select 
month(issue_date) as Month_Number,
DATENAME(Month,issue_date) as Month_Name,
Count(id) as Total_Loan_Application,
Sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Received
from bankloan.dbo.financial_loan_raw
group by month(issue_date), DateName(Month, issue_date)
order by month(issue_date)

--Bank Loan Report| overview - state

select
address_state as State,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_amount_received
from bankloan.dbo.financial_loan_raw
Group by address_state
order by address_state

--Bank Loan Report| overview - Term

select
term as Term,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_amount_received
from bankloan.dbo.financial_loan_raw
Group by term
order by term

--Bank Loan Report| overview - years employed

select
emp_length as Employee_Length,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_amount_received
from bankloan.dbo.financial_loan_raw
Group by emp_Length
order by emp_Length

--Bank Loan Report| overview - years employed

select
emp_length as Employee_Length,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_amount_received
from bankloan.dbo.financial_loan_raw
Group by emp_Length
order by emp_Length

--Bank Loan Report| overview - purpose

select
purpose as Purpose_Of_Loan,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_amount_received
from bankloan.dbo.financial_loan_raw
Group by purpose
order by purpose

--Bank Loan Report| overview - home ownership

select
home_ownership as Home_Ownership,
count(id) as total_loan_applications,
sum(loan_amount) as total_funded_amount,
sum(total_payment) as total_amount_received
from bankloan.dbo.financial_loan_raw
Group by home_ownership
order by home_ownership
