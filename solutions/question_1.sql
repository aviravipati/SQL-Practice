

with mean_tbl as (
select d.CALDATE,count(*)
from date d inner join sales s on s.dateid=d.dateid group by d.CALDATE)

select count(distinct d.CALDATE)
from date d inner join sales s on s.dateid=d.dateid 
where s.QTYSOLD<(select q_percenmean_sold from mean_tbl)
;

select b.c,a.c,((b.c-a.c)*100.0)/a.c as per_change from
(select STRFTIME('%Y-%m-%d', saletime) as dt, count(1) as c 
from sales where STRFTIME('%Y-%m-%d', saletime) ='2008-09-09' group by dt) a,
(select STRFTIME('%Y-%m-%d', saletime) as dt, count(1) as c
from sales where STRFTIME('%Y-%m-%d', saletime) ='2008-09-10' group by dt) b
;

with venue_tbl as (
select v.venuecity, count(s.salesid) as c
from event e inner join 
sales s on s.eventid=e.eventid 
inner join venue v on e.venueid=v.venueid
group by v.venuecity
)
select venuecity from (
select venuecity,RANK() OVER(order by c desc) as  rank from venue_tbl ) a
where rank<=3
;

SELECT count(DATEID)
FROM(
    SELECT DATEID, total_sales, cnt, (avg(total_sales) over ()) *0.25 as avg_sales_25, (avg(cnt) over ()) *0.25 as avg_cnt_25
    FROM (
            SELECT DATEID, SUM(QTYSOLD) as total_sales, count(salesid) as cnt
            FROM SALES
            GROUP BY DATEID
            ) as t1
)
WHERE cnt<avg_cnt_25
;


select count(USERID) from users u inner JOIN

select sellerid, username, (firstname ||' '|| lastname) as name,
city, sum(qtysold)
from sales, date, users
where sales.sellerid = users.userid
and sales.dateid = date.dateid
and year = 2008
and city = 'San Diego'
group by sellerid, username, name, city
order by 5 desc
limit 5;


--Consider the previous tables:
--Hotel (Hotel_ID, Hotel_name, location)  
--Rooms (Hotel_ID, Room_no, type, rent)

--Q. List all the hotel rooms and their rent from New York. 
--Besides that, if rent is NULL, in place of price, replace it with the text “Not Available.”

select H.Hotel_name, R.room_no, (CASE when R.rent is NULL then "Not Available" else R.rent END) as rent
(select Hotel_ID,Hotel_name from Hotel H where location='New York') H inner join Rooms R on (R.Hotel_ID=H.Hotel_ID)

Q. As a business strategy, the company needs to revisit the room types based on rent. 
(Assume that currently the types are tagged on factors like location and other local factors)



Get the number of rooms for each new category.

We can approach this problem in two steps: 
First, we modify the type column with a CASE statement 
Then we apply Group by and count to get the desired result. 
	
We will combine both these steps in a single query

select 
    CASE 
      WHEN rent >= 1000
      THEN ‘AAA’
      WHEN rent >= 600
      THEN ‘AA’
      ELSE ‘A’
    END AS type, count(*) as num_rooms
from Rooms
group by
    CASE 
      WHEN rent >= 1000
      THEN ‘AAA’
      WHEN rent >= 600
      THEN ‘AA’
      ELSE ‘A’
    END

You can do the grouping by a different number of columns using the CASE operator within a single query.
You can use a Case Statement with Where, Having, Order by clause as well. 


/*


Till now we have covered fundamental topics of SQL. But we still need to understand Joins and few analytical functions to be ready for the interview. 

Here are few sample interview-level problems.  

1. Consider the following tables from a literary database. 

Authors (author_id, first_name, last_name, country, birth_year)
Books (title, author_id, publication_year)
Nobel_Winners (author_id, award_year)

Write SQL expressions for the following: 

List titles of books from Argentina or Peru
*/
select B.title from Authors A inner join Books B on (A.author_id=B.author_id)
where A.country in ('Argentina','Peru')
/*

List title of books by Nobel Prize winners that were published after 1940
*/
select title from Books 
where publication_year > 1940
and author_id in (select distinct author_id from Nobel_winners)
/*
List last names of Nobel Prize winners from Japan
*/
select B.last_name from Nobel_Winners A inner join Authors B on (A.author_id=B.author_id)
where B.country='Japan'
/*
List pair of authors_id, both of whom were born after 1920. Only list each pair once.
*/
with Author_A as (
select author_id from Authors B 
where birth_year > 1920 )

select * from Author_A
/*
2. Consider the relation: Examinee (regno, name, score), where regno is the primary key.
Write a relational algebra expression to find the names which appear more than once in Examinee. 
Write a SQL query to list regno of examinees who have a score greater than the average score. 
Suppose the relation Appears (regno, center _code), specifies the center where an examinee appears. 
Write a SQL query to list the center _code having at least an examinee with a score greater than 80

Try writing SQL queries on your own. The above questions are among many questions that are frequently asked in the interviews. 

 We need to understand a few more concepts to write an efficient query for the above questions. We need to understand details on: 
Joins (Inner, Outer, Right Join, Left Join, Self Join, Cross Join)
Analytical and Window Functions. 
Miscellaneous functions. 

We will cover these topics discussed with interview-like questions in the live class. 
See you all in the live class!

*/

select 

