with orders as ( select * from {{ source('shopify_tables', 'order') }}),

order_count as ( 
    select
        customer_id,
        case when count(id) > 1 then 1 else 0 end as repeat_customer

    from orders
    group by 1
),

first_order_date as ( 
    select
        customer_id,
        min(created_at) as datetime

    from orders
    group by 1
),

order_date_repeat as ( 
    select 
        order_count.customer_id,
        first_order_date.datetime,
        order_count.repeat_customer

    from order_count
    inner join first_order_date 
        on order_count.customer_id = first_order_date.customer_id
),

first_order as (
    select
        distinct id as order_id, customer_id

    from orders
    where (orders.customer_id, orders.created_at) in (select customer_id, datetime from order_date_repeat)
),

first_order_joined as (
    select 
        first_order.order_id, 
        first_order.customer_id, 
        order_date_repeat.datetime,
        order_date_repeat.repeat_customer
        
    from first_order
    inner join order_date_repeat
        on first_order.customer_id = order_date_repeat.customer_id
)

select * from first_order_joined
