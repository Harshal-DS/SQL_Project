use  walmartproject;

select *
from walmartsales;

ALTER TABLE walmartsales
MODIFY Date date;

ALTER TABLE walmartsales
MODIFY `Invoice ID`VARCHAR (40),
MODIFY Branch char(1),
MODIFY city VARCHAR(20),
MODIFY `Customer type` VARCHAR(20),
MODIFY gender VARCHAR(20),
MODIFY `Product line` VARCHAR(40),
MODIFY payment VARCHAR(20);


alter table walmartsales
rename column `Invoice ID`  to Invoice_id;
alter table walmartsales
rename column `Customer type`  to Customer_type,
rename column `Product line`  to product_line,
rename column `Unit price`  to Unit_price,
rename column `gross margin percentage` to gross_margin_percentage,
rename column `gross income` to gross_income,
rename column `Customer ID` to Customer_ID;


ALTER TABLE walmartsales
MODIFY total double(10,2);

ALTER TABLE walmartsales
ADD primary key(Invoice_id);

select Branch,sum(Total)
FROM walmartsales
group by branch;


-- 1
ALTER table walmartsales
ADD column Date_month int;

SET SQL_SAFE_UPDATES = 0;
UPDATE  walmartsales
set date_month= month(date);

select Date_month,branch,sum(Total)
FROM walmartsales
group by date_month ,branch
order by Date_month;

create view Sales_GrowthRate as
with sales_analysis as
(SELECT Date_month,branch,SUM(Total) AS total_sum,
LEAD(SUM(Total)) OVER (PARTITION BY branch ORDER BY Date_month) AS next_month_total_sum
FROM walmartsales
GROUP BY Date_month, branch
ORDER BY Date_month, branch)
select  *,(next_month_total_sum)-(total_sum) as 'Growth_rate',((next_month_total_sum)-(total_sum))/total_sum as 'Growth_percent' from sales_analysis;
	
select* FROM Sales_GrowthRate;


-- 2
select *
from walmartsales;

select product_line,Branch,round(sum(cogs-gross_income),2) AS profit_margin
from walmartsales
group by product_line,Branch
order by product_line,Branch;


-- 3
select count( distinct Customer_ID)
from walmartsales;

select customer_id,round(avg(total)) as Average_Purchase,
case 
when avg(total) <300 then 'Low'
when avg(total) <340 then 'Medium'
else 'High'
end as Customer_Segmentation
from walmartsales
group by Customer_ID
order by Customer_ID,avg(total);

-- 4
select product_line,round(avg(total))
from walmartsales
group by product_line;


with productline1 as
(select product_line,total,
case
when product_line='health and beauty' then 324
when product_line='electronic accessories' then 320
when product_line='home and lifestyle' then 337
when product_line='food and beverages' then 323
when product_line='fashion accessories' then 305
else 332
end as Average_productlineSales
from walmartsales)
select * ,total-Average_productlineSales as Anomalies_behaviour
from productline1;
select count(Anomalies_behaviour<-200)
from productline1;

-- 5
SELECT city ,payment,count(Invoice_id) AS Payment_Method_count
FROM walmartsales
group by city,payment
order by city ,count(Invoice_id) desc,payment;


-- 6
SELECT month(date)AS 'Month_No.',monthname(date) AS Month,gender,sum(total) AS sales
FROM walmartsales
group by month(date),monthname(date),gender
order by month(date),gender;

-- 7
SELECT Product_line,customer_type,count(Invoice_id) as 'NO.of CustomerType'
from walmartsales
group by Product_line,customer_type
order by Product_line,customer_type;

SELECT Product_line,count(Invoice_id) as 'NO.of Member CustomerType'
from walmartsales
group by Product_line,customer_type
having customer_type="Member"
order by count(Invoice_id) desc;

SELECT Product_line,count(Invoice_id) as 'NO.of Normal CustomerType'
from walmartsales
group by Product_line,customer_type
having customer_type="Normal"
order by count(Invoice_id) desc;

-- 8
select Customer_ID,month(date) AS Month_Number,count(Customer_ID) AS REPEAT_PURCHASE_COUNT
from walmartsales
group by Customer_ID,month(date)
order by Customer_ID,month(date),count(Customer_ID);

-- 9
SELECT 
    Customer_ID, SUM(total) AS Sales_Revenue
FROM
    walmartsales
GROUP BY Customer_ID
ORDER BY Sales_Revenue DESC
LIMIT 5;

-- 10
SELECT 
    DAYNAME(date) AS Week_Day, SUM(total) AS Sales
FROM
    walmartsales
GROUP BY DAYNAME(date)
ORDER BY SUM(total) DESC;
