--How many days were there where the number of tickets sold was less than 25% of the mean?


--What was the percent change in orders between September 9 & 10?

select round(((b.c-a.c)*100)/a.c,1) as per_change from
(select STRFTIME('%Y-%m-%d', saletime) as dt, cast(count(1) as flaot) as c 
from sales where STRFTIME('%Y-%m-%d', saletime) ='2008-09-09' group by dt) a
join 
(select STRFTIME('%Y-%m-%d', saletime) as dt, cast(count(1) as float) as c
from sales where STRFTIME('%Y-%m-%d', saletime) ='2008-09-10' group by dt) b
on (1=1);

--Find the top 3 cities for sales. [number of sales]
select venuecity from (
select v.venuecity, count(s.salesid) as number_of_sale from sales s join event e on (s.eventid=e.eventid) 
join venue v on (e.venueid=v.venueid)
group by v.venuecity
order by 2 desc
limit 3 ) a
;

--What was the top event in Los Angeles?
--Note: Here top event means in terms of the overall price paid. 
WITH event_rankings AS (
	  -- Returns rankings of events by sales per city
	  SELECT
	    v.venuecity,
	    e.eventid,
	    e.eventname,
	    SUM(pricepaid) AS total_paid
		--,	    ROW_NUMBER() OVER (PARTITION BY v.venuecity ORDER BY SUM(pricepaid) DESC) AS rnk
	  FROM event e
	  JOIN sales s
	    ON s.eventid = e.eventid
	  JOIN venue v
	    ON v.venueid = e.venueid
      where  v.venuecity='Los Angeles'
	  GROUP BY
	    v.venuecity,
	    e.eventid,
	    e.eventname
	  ORDER BY
	  	 4 desc 
	)
	
 SELECT
	  *
	FROM event_rankings
	limit 1
	;


--How many users have bought a ticket to the category called 'Musicals'?
select count(distinct buyerid) from event e join sales s 
on e.eventid=s.eventid where catid in (
select catid from category 
where catname='Musicals' );


--How many tickets were sold by resellers (someone who bought tickets
--for an event and later sold tickets to that same event)?

select sum(b.qtysold) from sales a inner join sales b on (a.buyerid=b.sellerid and a.eventid=b.eventid and a.saletime<b.saletime);

SELECT SUM(s2.qtysold) AS total_ticktes_resold
	  FROM sales s1
	  JOIN sales s2
	    -- Two sales for the same event
	    ON s2.eventid = s1.eventid
	      -- The second transaction happened after the frist
	      AND s2.saletime > s1.saletime
	      -- The seller of the second transaction was the buyer in the first transaction
	      -- This means they're reselling the tickets
	      AND s2.sellerid = s1.buyerid;

--Which holiday had the most ticket sales?


--How many buyer pairs have attended three or more events together?



--How many users have bought tickets to an out-of-state event?




select round(((((select count(dateid) from sales where dateid = 
(select dateid from date where caldate = '2008-09-10'))*1.0/
 ( select count(dateid) from sales where dateid = (select dateid from date where caldate = '2008-09-09')))-1)*100),1)
 ;


with venue_tbl as (
select v.venuecity, count(s.salesid) as c
from event e inner join 
sales s on s.eventid=e.eventid 
inner join venue v on e.venueid=v.venueid
group by v.venuecity
)
select venuecity from (
select venuecity,RANK() OVER(order by c desc) as  rank 
from venue_tbl ) a
where rank<=3
;
select eventname from (
select e.eventid,e.eventname,sum(s.pricepaid) 
from sales s inner join event e 
on s.eventid=e.eventid 
inner join 
venue v on e.venueid=v.venueid where venuecity='Los Angeles'
group by 1,2
order by 3 desc 
limit 1)
;


with event_venue as
(select a.* from event a  
join venue b 
on a.venueid = b.venueid
where venuecity='Los Angeles' ),

sls as (
select eventid , sum(pricepaid) sg from sales
group by eventid )

select e.eventname  from 

event_venue e join sls  s 
on e.eventid = s.eventid
order by sg desc limit 1;




 
 select 
 count(distinct buyerid) from sales s 
 where s.eventid in
 (select e.eventid from event e  join  category c  on e.catid=c.catid  
 where c.catname ='Musicals');


select sum(sell.qtysold) from sales as sell 
JOIN sales as buy ON sell.eventid = buy.eventid 
and sell.sellerid = buy.buyerid and sell.saletime > buy.saletime;


select dt from (
select dt, qnty from
(select date(SALETIME) as dt,sum(qtysold) as qnty from sales
group by 1 ) a inner join date d on a.dt=d.caldate
where d.holiday=1
order by 2 DESC
limit 1) a
;

select * from date where holiday=1;
select date(SALETIME) as dt,sum(qtysold) as qnty from sales
group by 1 ;


select a.buyerid,b.buyerid, 
COUNT(DISTINCT a.eventid) AS num_events_attended_together from
sales  a join sales  b
on a.eventid=b.eventid and b.buyerid > a.buyerid
group by 1,2
HAVING num_events_attended_together>=3
;

select * from sales
where buyerid='28094'
;


SELECT
	  s1.buyerid AS buyer_a,
	  s2.buyerid AS buyer_b,
	  COUNT(DISTINCT s1.eventid) AS num_events_attended_together
	FROM sales s1
	JOIN sales s2
	  ON s2.eventid = s1.eventid
	    AND s2.buyerid > s1.buyerid
	GROUP BY
	  buyer_a,
	  buyer_b
	HAVING num_events_attended_together >= 3
	
;

select count(DISTINCT u.userid )from sales s inner join   
users u on s.buyerid=u.userid
inner join event e on e.eventid=s.eventid
inner join venue v on v.venueid=e.venueid
where v.venuestate != u.state 
;


SELECT
    COUNT(DISTINCT u.userid)
FROM sales a
JOIN users u
    on a.buyerid = u.userid
JOIn event e
    on a.eventid = e.eventid
JOIN venue v
    on e.venueid = v.venueid
WHERE u.state != v.venuestate
;


with customers AS (
select 'C1' as customer_id, 'CN1' as customer_name
UNION ALL
select 'C3', 'CN3'
UNION ALL
select 'C4', 'CN4'
)
,
orders as (
select 'O1' as order_id, 'C1' as customer_id
UNION ALL
select 'O2', 'C1'
UNION ALL
select 'O3', 'C2'
UNION ALL
select 'O4', 'C5'
)


Select c.customer_id
from customers c Left join orders o
on c.customer_id = o.customer_id
and o.customer_id = 'C1'
;


with sales as
(
select '2020-01-01' as sales_date, 500 as sales_amount, 'INR' as currency
UNION ALL
select '2020-01-01' , 100, 'GBP'
UNION ALL
select '2020-01-02', 1000, 'INR'

UNION ALL
select '2020-01-02', 500, 'GBP'
UNION ALL
select '2020-01-03', 500, 'INR'
UNION ALL
select '2020-01-17', 200, 'GBP'
),

exchange_rates as
(
select 'INR' as source_currency, 'USD' as target_currency, 0.014 as
exchange_rate, '2019-12-31' as effective_start_date
UNION ALL
select 'INR', 'USD', 0.015, '2020-01-02'
UNION ALL
select 'GBP', 'USD', 1.32, '2019-12-20'
UNION ALL
select 'GBP', 'USD', 1.3, '2020-01-01'
UNION ALL
select 'GBP', 'USD', 1.35, '2020-01-16'
)
,

--Write a query which converts the local currency to USD 
--and displays the rates which are applied
--(based on the sales_date and effective_start_date)
 derived_erates as (
select *, COALESCE ( lead(effective_start_date,1) 
over(partition by source_currency,target_currency) , date("2099-12-31")) as previous_dt 
 from exchange_rates 
)
select s.sales_amount*d.exchange_rate as usd_sales_amt,d.exchange_rate,s.sales_date,s.currency from sales s inner join derived_erates d on s.currency=d.source_currency
and s.sales_date >=d.effective_start_date and s.sales_date<d.previous_dt

;


with sales as
(
select '2020-01-01' as sales_date, 500 as sales_amount, 'INR' as currency
UNION ALL
select '2020-01-01' , 100, 'GBP'
UNION ALL
select '2020-01-02', 1000, 'INR'

UNION ALL
select '2020-01-02', 500, 'GBP'
UNION ALL
select '2020-01-03', 500, 'INR'
UNION ALL
select '2020-01-17', 200, 'GBP'
),

exchange_rates as
(
select 'INR' as source_currency, 'USD' as target_currency, 0.014 as
exchange_rate, '2019-12-31' as effective_start_date
UNION ALL
select 'INR', 'USD', 0.015, '2020-01-02'
UNION ALL
select 'GBP', 'USD', 1.32, '2019-12-20'
UNION ALL
select 'GBP', 'USD', 1.3, '2020-01-01'
UNION ALL
select 'GBP', 'USD', 1.35, '2020-01-16'
)
,
 new_exchange_rates as
(
select source_currency, target_currency, exchange_rate,
effective_start_date,
case when effective_end_date is null then '9999-99-99' else
effective_end_date end as effective_end_date
from
(
select source_currency, target_currency, exchange_rate,
effective_start_date,
lead(effective_start_date,1) over (partition by source_currency order by
effective_start_date) as effective_end_date
from
exchange_rates
)
)

select a.sales_date, a.sales_amount, a.currency,
b.target_currency, b.exchange_rate,
b.effective_start_date, b.effective_end_date
from sales a
left join new_exchange_rates b
on a.currency = b.source_currency
and a.sales_date >= b.effective_start_date
and a.sales_date < b.effective_end_date
;


with sales as
(
select '2020-01-01' as sales_date, 500 as sales_amount, 'INR' as currency
UNION ALL
select '2020-01-01' , 100, 'GBP'
UNION ALL
select '2020-01-02', 1000, 'INR'

UNION ALL
select '2020-01-02', 500, 'GBP'
UNION ALL
select '2020-01-03', 500, 'INR'
UNION ALL
select '2020-01-17', 200, 'GBP'
),

exchange_rates as
(
select 'INR' as source_currency, 'USD' as target_currency, 0.014 as
exchange_rate, '2019-12-31' as effective_start_date
UNION ALL
select 'INR', 'USD', 0.015, '2020-01-02'
UNION ALL
select 'GBP', 'USD', 1.32, '2019-12-20'
UNION ALL
select 'GBP', 'USD', 1.3, '2020-01-01'
UNION ALL
select 'GBP', 'USD', 1.35, '2020-01-16'
)
,
 new_exchange_rates as
(
select source_currency, target_currency, exchange_rate,
effective_start_date,
case when effective_end_date is null then '9999-99-99' else
effective_end_date end as effective_end_date
from
(
select source_currency, target_currency, exchange_rate,
effective_start_date,
lead(effective_start_date,1) over (partition by source_currency order by
effective_start_date) as effective_end_date
from
exchange_rates
)
)

select a.sales_date, a.sales_amount, a.currency,
b.target_currency, b.exchange_rate,
b.effective_start_date, b.effective_end_date
from sales a
left join new_exchange_rates b
on a.currency = b.source_currency
and a.sales_date >= b.effective_start_date
and a.sales_date < b.effective_end_date
;



create table demo (startDate datetime);

insert demo (startDate) values ('2015-04-10 3:46:07');
insert demo (startDate) values ('2015-04-09 3:47:37');
insert demo (startDate) values ('2015-04-08 3:48:07');
insert demo (startDate) values ('2015-04-07 3:43:44');
insert demo (startDate) values ('2015-04-06 3:39:08');
insert demo (startDate) values ('2015-04-03 3:47:50');

with start_date_tbl as
(
select '2015-04-10 3:46:07' as startDate
UNION ALL
select '2015-04-09 3:47:37'
UNION ALL
select '2015-04-08 3:48:07'
UNION ALL
select '2015-04-07 3:43:44'
UNION ALL
select '2015-04-06 3:39:08'
)
select   cast(startDate as time)   as avg_start_date
from start_date_tbl

;

with countries as
(
select 'INC' as country 
UNION ALL
select 'USA' as country 
UNION ALL
select 'CHN' as country 
UNION ALL
select 'AFG' as country 
UNION ALL
select 'SRI' as country 
UNION ALL
select 'BNG' as country 
)

select a.country||"|"||b.country from countries 
where a.country not in (select country from countries b)
;



WITH fruit_baskets as 
(
  SELECT
    * 
  FROM
    UNNEST(
      ARRAY<STRUCT<fruit ARRAY<STRING>,basket STRING>>[
        (['bananas', 'apples', 'oranges'], 'basket 1'),
        (['bananas', 'oranges'], 'basket 2'),
        (['bananas', 'apples'], 'basket 3')
      ]
    )
  AS fruit
)

SELECT * 
FROM fruit_baskets 
CROSS JOIN UNNEST(fruit) as fruit_unnest