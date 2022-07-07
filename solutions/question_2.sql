select round(((b.c-a.c)*100)/a.c,1) as per_change from
(select STRFTIME('%Y-%m-%d', saletime) as dt, cast(count(1) as flaot) as c 
from sales where STRFTIME('%Y-%m-%d', saletime) ='2008-09-09' group by dt) a
join 
(select STRFTIME('%Y-%m-%d', saletime) as dt, cast(count(1) as float) as c
from sales where STRFTIME('%Y-%m-%d', saletime) ='2008-09-10' group by dt) b
on (1=1);


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

select count(distinct buyerid) from event e join sales s 
on e.eventid=s.eventid where catid in (
select catid from category 
where catname='Musicals' );


 
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



