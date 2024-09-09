# mySQL DATA CLEANING & SALES ANALYSIS OF ADDIDAS 

use sneakers;
select *from Adidas_sales;
alter table `sneakers`.`addidas_sales`
rename to `sneakers`.`adidas_sales`;

#-- Change the name of the column --
alter table`adidas_sales`
rename column`Retailer ID` to Retailer_id;
alter table `adidas_sales`
rename column `Invoice Date` to Invoice_date;
alter table`adidas_sales`
rename column `Price Per Unit` to Price_per_unit;
alter table `adidas_sales`
rename column `Units sold` to Units_sold;
alter table `adidas_sales`
rename column `Total sales` to Total_sales;
alter table `adidas_sales` 
rename column `Operating profit` to Operating_profit;
alter table `adidas_sales`
rename column `sales method` to Sales_method;
alter table `adidas_sales`
rename column `operating margin ` to `operating_margin`;

#-- Check the Data type of a columns --
select column_name, data_type from information_schema.columns
 where table_schema ="sneakers" and table_name="adidas_sales";
 
#-- Find out the blank values of each column --
select * from adidas_sales where retailer="" or retailer_id="" 
 or invoice_date=" "or region=" " or state =" " or city =" " or product =" "
 or price_per_unit= " " or units_sold= "" or Total_sales=""  or operating_profit=" " 
 or sales_method = "";
 
#-- Deleting rows with missing values --
Delete from adidas_sales Where Units_sold = ''; 

#--Find out the null value in each column --
select * from adidas_sales where retailer is null or retailer_id  is null 
 or invoice_date is null or region is null  or state  is null  or city  is null 
 or product  is null or price_per_unit is null  or units_sold is null 
 or Total_sales is null or operating_profit is null or sales_method  is null ;
 
 # -- Conversion of the Date from text to date data type
 ALTER TABLE adidas_sales MODIFy COLUMN Invoice_date DATE;
 
 #--updating the date format--
UPDATE adidas_sales
SET Invoice_date = STR_TO_DATE(Invoice_date, '%m/%d/%Y')
WHERE Invoice_date LIKE '%/%/%';
SET SQL_SAFE_UPDATES = 0;
select * from adidas_sales where invoice_date = 01/01/2021;

#--converting totale_sales data type from text to intiger--
alter table adidas_sales modify column total_sales int;

#-- updating the rows of Total Sales column
update adidas_sales set total_sales = replace(total_sales,','," ");
update adidas_sales set total_sales = replace(replace (operating_profit, ',',''),'$','');

#--conversion of operating profit  from text to int--
select operating_profit from adidas_sales;
alter table Adidas_sales modify column operating_profit int;

#-- updating the rows of operating profit column--
update adidas_sales set operating_profit =0 where operating_profit='';
update adidas_sales set operating_profit = replace(replace (operating_profit, ',',''),'$','');

#-- Conversion of the operating margin from text to date data type--
alter table adidas_sales modify column Operating_Margin float;

#--updating the row os operating_margin --
update adidas_sales set operating_margin=replace(operating_margin,'%','');

#--updating the column operting profit --
update adidas_sales set operating_margin= operating_margin/100;
select operating_margin from adidas_sales;

#-- Conversion of the profit per unit from text to date data type--
alter table  adidas_sales modify column price_per_unit int;

#-- updating the rows of price per unit column--
update adidas_sales set price_per_unit=replace(price_per_unit, '$', '');
 
#--to check the data type of all the column in the table--
select column_name, data_type from information_schema.columns
 where table_schema="sneakers" and table_name = "adidas_sales";
 
#-- converting the null value in price_per_unit--
update Adidas_sales set price_per_unit= total_sales/units_sold where price_per_unit is null;
select *  from adidas_sales where price_per_unit=null;

#-- updating the values of total_sales--
update adidas_sales set total_sales = price_per_unit * units_sold;
select *  from adidas_sales where total_sales=null;


#--update the value of the product column--
update adidas_sales set product = replace(replace(product,"Men's aparel", "Men's Apparel"),
"Men''s'Apparel","Men's Apparel");

#--find the dupilicate values from the table--
select retailer, retailer_id, invoice_date, region, state, city, product,
price_per_unit, units_sold, total_sales, operating_profit, sales_method, count(*) as num_duplicate 
from adidas_sales
group by retailer, retailer_id, invoice_date, region, state, city, product,
price_per_unit, units_sold, total_sales, operating_profit, sales_method Having count(*) > 1;

#3. Analyzing
select distinct retailer from adidas_sales; 
select distinct region from adidas_sales; 
select distinct state from adidas_sales; 
select distinct city from adidas_sales; 
select distinct product from adidas_sales; 
select distinct sales_method from adidas_sales; 

#--for analyzing i create three addition columns accordingly Year Months & season--
alter table adidas_sales 
add column year int,
add column Months varchar (10),
add column Season varchar (10);

#--Renaming the columns of the table--
alter table `sneakers`. `adidas_sales` 
rename column `year`to `Year`;
alter table `sneakers`. `adidas_sales` 
rename column `Months`to `Month`;

#--upadate the new column with values--
update adidas_sales set
Year = YEAR(invoice_date),
Month = date_format(invoice_date,'%b'),
Season = Case
when Month(invoice_date) in (3,4,5) then 'Summer'
when Month(invoice_date) in (6,7,8) then 'Spring'
when Month(invoice_date) in (9,10,11) then 'Monsoon'
Else 'winter'
end;

#   1.GROWTH ANALYSES:-
#   On basis of season 1.1
select season, sum(round(total_sales/1000000,2)) as Num_total_sales,
sum(units_sold) as total_units_sold from adidas_sales
group by season
order by sum(total_sales) desc;

#   On basis of Year 1.2
#-- montly sales analysis for 2020 & 2021--
select date_format(invoice_date,'%b') as Month,
sum(case when Year(invoice_date) =2020 then total_sales else 0 end) as total_sales_2020,
sum(case when Year(invoice_date)= 2021 then total_sales else 0 end) as total_sales_2021 
from adidas_sales
group by date_format(invoice_date,'%b')
order by month;

#-- Growth rate on basis of year--
with cte as (select 
sum(case when Year(invoice_date) =2020 then round(total_sales/1000000,2)end) as total_sales_2020,
sum(case when Year(invoice_date)=2021 then round(total_sales/1000000,2)end) as total_sales_2021
 from adidas_sales)
select total_sales_2020, 
total_sales_2021, 
round(((total_sales_2021 - total_sales_2020)/total_sales_2020)*100,2) as growth_rate 
from cte;

#    2.GEOAPARTIAL ANALYSIS:-
# -- On the basis of Region 2.1--
select region,sum(round(total_sales/1000000,2)) as total_sales 
from adidas_sales
group by region
order by total_sales desc;

#-- on the basis of state (top, bottom 10) 2.2--
-- > Top 10
select state ,sum(round(total_sales/1000000,2)) as total_sales_state
from adidas_sales
group by state
order by total_sales_state desc
limit 10;

-- > Bottom 10 state
select state ,sum(round(total_sales/1000000,2)) as total_sales_state
from adidas_sales
group by state
order by total_sales_state asc
limit 10;

#-- on the basis of city (top,bottom 10) 2.1 --
-- > Top 10
select city, sum(round(total_sales/1000000,2)) as total_sales_city 
from adidas_sales 
group by city
order by total_sales_city desc
limit 10;

-- > Bottom 10 
select city, sum(round(total_sales/1000000,2)) as total_sales_city 
from adidas_sales 
group by city
order by total_sales_city asc
limit 10;

#    3.PRODUCT ANALYSIS :-
#-- Best selling product 3.1--
select product, sum(round(total_sales/1000000,2)) as total_product,
sum(units_sold) as total_units_sold 
from adidas_sales
group by product
order by total_product and total_units_sold desc;

#-- Product with highest & lowest growth rate--
with cte as (select product, 
sum(case when Year(invoice_date) =2020 then round(total_sales/1000000,2)end) as total_sales_2020,
sum(case when Year(invoice_date)=2021 then round(total_sales/1000000,2)end) as total_sales_2021
 from adidas_sales
 group by product)
select total_sales_2020, 
total_sales_2021, 
round(((total_sales_2021 - total_sales_2020)/total_sales_2020)*100,2) as growth_rate 
from cte 
order by growth_rate desc;

#    4.ANALYSING OF REPEATED CUSTOMER :-
select retailer, count(*) as purchase_count
from adidas_sales
group by retailer
having purchase_count>1 
order by purchase_count desc;

#    5.SALES METHOD ANALYSIS :-
select sales_method, sum(round(total_sales/1000000,2)) as total_sales_method,
sum(units_sold) as total_units_sold 
from adidas_sales
group by sales_method
order by total_sales_method, total_units_sold desc;

                                                # END #