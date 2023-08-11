create database job
use job 
CREATE TABLE job_data
(
    ds DATE TIMESTAMP,
    job_id INT NOT NULL,
    actor_id INT NOT NULL,
    event VARCHAR(15) NOT NULL,
    language VARCHAR(15) NOT NULL,
    time_spent INT NOT NULL,
    org CHAR(2)
);
 	

      
INSERT INTO job_data (ds, job_id, actor_id, event, language, time_spent, org)
VALUES ('2020-11-30', 21, 1001, 'skip', 'English', 15, 'A'),
    ('2020-11-30', 22, 1006, 'transfer', 'Arabic', 25, 'B'),
    ('2020-11-29', 23, 1003, 'decision', 'Persian', 20, 'C'),
    ('2020-11-28', 23, 1005,'transfer', 'Persian', 22, 'D'),
    ('2020-11-28', 25, 1002, 'decision', 'Hindi', 11, 'B'),
    ('2020-11-27', 11, 1007, 'decision', 'French', 104, 'D'),
    ('2020-11-26', 23, 1004, 'skip', 'Persian', 56, 'A'),
    ('2020-11-25', 20, 1003, 'transfer', 'Italian', 45, 'C');
          

SELECT * FROM job_data

----/** 1.)Jobs reviewed per hour per day for nov 2020**/ ---

SELECT ds,count(job_id) as num_jobs,
sum(time_spent) as total_time_sec,
round(count(job_id)/sum(time_spent)*3600,0) as job_reviewed_perhour_perday
FROM job_data 
WHERE  ds BETWEEN '2020-11-01' AND '2020-11-30'
group by ds  
order by ds 

---/**Insight: we can see that there are 218 job reviewed on 28th of nov which is hightest among all days.**/----


 ---/**2.)calculate seven days rolling average of throughput explain whether you prefer using the daily metric or 
the 7-day rolling average for throughput, and why.**/----

WITH throughput_average AS (
SELECT ds, event,COUNT(job_id) AS num_jobs, SUM(time_spent) AS total_time
FROM job_data
WHERE  ds BETWEEN '2020-11-01' AND '2020-11-30'
group by ds)
SELECT ds,event,
ROUND(1.0*sum(num_jobs) OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) / SUM(total_time) OVER (ORDER
 BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS throughput_7d
FROM throughput_average;

or 
select ds as dates , round(count(event)/sum(time_spent),2) as weekly_throughput
from job_data

---daily throughput--
select ds as Dates, round(count(event)/sum(time_spent),2) as Daily_throughput
from job_data
group by ds
order by ds

----/**Insight: 7 days rolling avg of throughput is 0.03  but we can on daily basis metrics goes up and down so it will be 
greate to choose daily metrics if trends goes change on daily basis.**/---- 

--/**3.) Dublicate rows**/--

select  job_id ,  count(*) as dup_count
from job_data
group by job_id
having  count(*)>1

----or-----
WITH CTE AS (select *, ROW_NUMBER() OVER (PARTITION BY job_id order by job_id) rownum
               from job_data)
select *
from CTE
where rownum>1 
  
---/**Insight: there is two duplicate data in the table that is job_id 23 **/----



---/**4) percent share of language of last 30 days**/ -----

WITH  Num_job  AS(SELECT   language , COUNT(job_id) as num_job 
				 FROM  job_data
			     WHERE ds BETWEEN '2020-11-01' AND '2020-11-30'
				 GROUP BY language),
 Total_job AS ( SELECT COUNT(job_id) as total_job 
	           FROM job_data
			   WHERE ds BETWEEN '2020-11-01' AND '2020-11-30')
SELECT language, round( num_job*100/total_job,2) as percentage_share_language
FROM Num_job
cross join Total_job 
group by language
order by    percentage_share_language DESC

----/** INSIGHT: persian has highest no. of percent share language**/ ---

    
 
 

 
 
    


