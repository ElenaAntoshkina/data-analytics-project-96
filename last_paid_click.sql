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
