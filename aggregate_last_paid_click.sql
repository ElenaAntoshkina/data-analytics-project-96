/*пункт 1 проектаwith tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.amount,
        l.created_at,
        l.closing_reason,
        l.status_id,
        row_number()
            over (partition by s.visitor_id order by visit_date desc)
        as rn
    from sessions as s
    left join leads as l
        on
            s.visitor_id = l.visitor_id
            and s.visit_date <= l.created_at
    where s.source not like 'organic'
)

select
    visitor_id,
    visit_date,
    utm_source,
    utm_medium,
    utm_campaign,
    lead_id,
    created_at,
    amount,
    closing_reason,
    status_id
from tab
where rn = 1
order by
    amount desc nulls last,
    visit_date asc nulls last,
    utm_source asc nulls last,
    utm_medium asc nulls last,
    utm_campaign asc nulls last
limit 10;

select * 
from leads;
select * 
from sessions;
select * 
from vk_ads
order by campaign_date ;
select * 
from ya_ads;*/
--пункт 3 проекта

with tab as (
    select
        l.visitor_id,
        s.visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.amount,
        l.created_at,
        l.closing_reason,
        l.status_id,
        row_number()
            over (partition by s.visitor_id order by visit_date desc)
        as rn
    from sessions as s
    left join leads as l
        on
            s.visitor_id = l.visitor_id
            and s.visit_date <= l.created_at
    where s.source not like 'organic'
),

tab2 as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        date_trunc('day', visit_date) as visit_date,
        count(visitor_id) as visitors_count,
        count(case
            when created_at is not null then 1
            else 0
        end) as leads_count,
        count(case
            when status_id = 142 or closing_reason = 'Успешная продажа' then 1
            else 0
        end) as purchases_count,
        sum(case
            when
                status_id = 142 or closing_reason = 'Успешная продажа'
                then amount
            else 0
        end) as revenue
    from tab
    where rn = 1
    group by date_trunc('day', visit_date), utm_source, utm_medium, utm_campaign
),

tab_cost as (
    select
        campaign_date,
        utm_source,
        utm_medium,
        utm_campaign,
        sum(daily_spent) as total_cost
    from vk_ads
    group by campaign_date, utm_source, utm_medium, utm_campaign
    union
    select
        campaign_date,
        utm_source,
        utm_medium,
        utm_campaign,
        sum(daily_spent) as total_cost
    from ya_ads
    group by campaign_date, utm_source, utm_medium, utm_campaign
)

select
    t2.visit_date,
    t2.utm_source,
    t2.utm_medium,
    t2.utm_campaign,
    tc.total_cost,
    t2.leads_count,
    t2.purchases_count,
    t2.revenue
from tab2 as t2
left join tab_cost as tc
    on
        t2.visit_date = tc.campaign_date
        and t2.utm_source = tc.utm_source
        and t2.utm_medium = tc.utm_medium
        and t2.utm_campaign = tc.utm_campaign
order by
    t2.revenue desc nulls last,
    t2.visit_date asc,
    t2.visitors_count desc,
    t2.utm_source asc,
    t2.utm_medium asc,
    t2.utm_campaign asc
limit 15;

	
		