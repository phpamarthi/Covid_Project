--1.
--Creating table and Union combine
Drop table if exists New_table
Select * into New_table
From HotelRevenue_Project..['2018$']
Union
Select * from HotelRevenue_Project..['2019$']
union
Select * from HotelRevenue_Project..['2020$']

select arrival_date_year
from New_table
Group by arrival_date_year


--2.
--Creating temp tables
Drop table if exists #temp_table
select *
into #temp_table
from HotelRevenue_Project..['2018$']
Union
select * from HotelRevenue_Project..['2019$']
Union
select * from HotelRevenue_Project..['2020$']

select *
from #temp_table


--Joining created table and existing tables with left join
Drop table if exists all_table
Create table all_table
(
hotel	nvarchar(255),
arrival_date_year	float,
arrival_date_month	nvarchar(255),
arrival_date_day_of_month	float,
stays_in_weekend_nights	float,
stays_in_week_nights	float,
meal	nvarchar(255),
market_segment	nvarchar(255),
adr	float,
Discount float,
cost float
)
Insert into all_table
Select 
year.hotel, year.arrival_date_year, year.arrival_date_month, year.arrival_date_day_of_month,
year.stays_in_weekend_nights, year.stays_in_week_nights, year.meal, year.market_segment, year.adr, mseg.Discount, cos.Cost

From New_table year
Left Join HotelRevenue_Project..market_segment$ mseg
on year.market_segment = mseg.market_segment
Left join HotelRevenue_Project..meal_cost$ cos
on year.meal = cos.meal

Select *
From all_table


--Computations
Select hotel, arrival_date_year, 
Format(Sum((stays_in_weekend_nights + stays_in_week_nights) * adr),'#,#') as Revenue,
Format(Sum((stays_in_weekend_nights + stays_in_week_nights) * (adr*(1-discount))), '#,#') as Revenue_afterdiscount
From all_table
group by rollup(hotel, arrival_date_year)

--Summary of Revenue
Select round(avg(adr),2) as averageadr, round(avg(discount),4) as averagediscount, Sum(stays_in_weekend_nights + stays_in_week_nights) as Totalnights,
Format(avg(adr) * Sum(stays_in_weekend_nights + stays_in_week_nights), '#,#') as ExpRev_B4Disc, 
Format(Sum(stays_in_weekend_nights + stays_in_week_nights) * avg(adr) * (1 - avg(discount)), '#,#') as ExpRev_afterDisc,
Format(Sum((stays_in_weekend_nights + stays_in_week_nights) * adr),'#,#') as ActualRevenue_B4Disc,
Format(Sum((stays_in_weekend_nights + stays_in_week_nights) * (adr*(1-discount))), '#,#') as ActualRevenue_afterdiscount
From all_table
