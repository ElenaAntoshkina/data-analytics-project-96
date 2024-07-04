select
    s.visitor_id,
    s.visit_date,
    s.source as utm_source,
    s.medium as utm_medium,
    s.campaign as utm_campaign,
    l.lead_id,
    l.created_at,
    l.amount,
    l.created_at,
    l.status_id
from sessions as s
left join leads as l
    on s.visitor_id = l.visitor_id
order by
    amount desc,
    visit_date asc, utm_source asc, utm_medium asc, utm_campaign asc;

