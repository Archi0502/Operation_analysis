/** INVESTIGATING METRIC SPIKE**/
/** THREE TABLE "USERS", "EVENTS","EMAIL_EVENTS" available on mode.com database**/

SELECT  * FROM tutorial.yammer_users
SELECT * FROM tutorial.yammer_events
SELECT * FROM tutorial.yammer_emails


/** 1.) weekly users engagement **/
SELECT EXTRACT( week from occurred_at) as weekly_engagment,
EXTRACT(MONTH FROM occurred_at) as months,
count(DISTINCT user_id) as num_user
FROM tutorial.yammer_events
where event_type = 'engagement'
group by 1,2
order by 3 desc

/* INSIGHT : we can see that, highest no. of engagment are on 30st week i.e. 4th week of july
with 1363 user engagment*/

/** 2.) User growth analysis**/
SELECT a.months,a.num_active_user,
     sum(a.num_active_user) over (order by a.months ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
     AS cumulative_growth_of_user
FROM (SELECT EXTRACT(month from created_at) as months,
      COUNT(DISTINCT user_id) as num_active_user
      FROM tutorial.yammer_users 
      where state = 'active'
       group by months
       limit 20) a
 
 /** INSIGHT: we can see that there is a continuous growth of users from 1st month to 8th month
(from 712 to 1347 users) but on 9th month it decline from 1347 to 330 users then it increase 
slightly(till 486 on 12th month).
but if we see cumulative growth from 1st month to 12th month then it is from 712 to 9381 active
users **/

/**3.)Weekly retention analysis**/
WITH cte1 AS (
    SELECT  extract(week from occurred_at) as week,
     count(distinct CASE WHEN event_type = 'engagement' then user_id else null end ) as user_engagment,
     count(distinct CASE WHEN event_type='signup_flow' then user_id else null end) as only_signup 
    FROM tutorial.yammer_events 
    group by week
    
),
cte2 AS (
    SELECT count(user_id) as total_signup
    FROM tutorial.yammer_users 
     
)
SELECT cte1.week, cte1.user_engagment, cte1.only_signup, 
round(100*cte1.user_engagment/cte2.total_signup,2) as rate_of_retention
FROM cte1
CROSS JOIN cte2 
ORDER BY 1 DESC
 
/** INSIGHT: the highest retention rate are in  28th week to 31th week i.e. 7% **/

/**4.) weekly engagement per device**/
select extract(week from occurred_at) as week,
       extract(month from occurred_at) as month,
       device,
       count(user_id) as num_users
FROM tutorial.yammer_events
where event_type ='engagement'
group by 1,2,3
order by 4 desc

 /** EMAIL ENGAGEMENT ANALYSIS**/
 
WITH cte1 as (
SELECT COUNT(user_id) as total_email_sent
FROM tutorial.yammer_emails
WHERE action IN('sent_weekly_digest','sent_reengagement_email')

),

cte2 as (
SELECT extract(month from occurred_at)as per_month,
        COUNT(distinct CASE WHEN action='email_open' then user_id else null end) as email_open,
        count(distinct CASE WHEN action ='email_clickthrough' THEN user_id ELSE NULL END)as email_clickthrough
        FROM tutorial.yammer_emails
        group by 1
        )
SELECT  cte2.per_month, cte2.email_open, cte2.email_clickthrough,cte1.total_email_sent,
      ROUND(100*cte2.email_open/cte1.total_email_sent,2) as rate_open_mail,
      ROUND(100*cte2.email_clickthrough/cte1.total_email_sent,2) as rate_clickthrough_mail
from cte1
cross join cte2
group by 1,2,3,4
        
  /** INSIGHT: rate of open_mail is continuously increasing with month but email_clickthrough is
  raise once but again decline in 8th month.
       