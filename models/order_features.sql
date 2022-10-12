with first_order_joined as ( select * from {{ ref('stg_shopify__order_keys') }}),

orders as ( select * from {{ source('shopify_tables', 'order') }}),

basket_size as ( select * from {{ ref('stg_shopify__order_line_basket') }} ),

order_features as (
    select
        orders.subtotal_price,
        case when orders.financial_status = 'paid' then 1 else 0 end as financial_status,
        case when orders.fulfillment_status = 'fulfilled' then 1 else 0 end as fulfillment_status,
        case when nullif(orders.referring_site, '') is not null then 1 else 0 end as referred,
        orders.total_discounts,
        orders.total_tip_received,
        orders.total_weight,
        basket_size.basket_size,
        first_order_joined.repeat_customer
    
    from first_order_joined
    left join orders 
        on first_order_joined.order_id = orders.id
        and first_order_joined.customer_id = orders.customer_id
        and first_order_joined.datetime = orders.created_at
    left join basket_size 
        on first_order_joined.order_id = basket_size.order_id
)

select * from order_features