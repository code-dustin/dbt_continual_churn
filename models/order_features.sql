with first_order_joined as ( select * from {{ ref('stg_shopify__order_keys') }}),

orders as ( select * from {{ source('shopify_tables', 'order') }}),

basket_size as ( select * from {{ ref('stg_shopify__order_line_basket') }} ),

order_features as (
    select
        first_order_joined.order_id,
        first_order_joined.customer_id,
        orders.subtotal_price,
        orders.financial_status,
        orders.fulfillment_status,
        case when nullif(orders.referring_site, '') is not null then True else False end as referred,
        orders.total_discounts,
        orders.total_tip_received,
        orders.total_weight,
        basket_size.basket_size,
        first_order_joined.datetime,
        case when first_order_joined.repeat_customer = 0 then False else True end as repeat_customer
    
    from first_order_joined
    left join orders 
        on first_order_joined.order_id = orders.id
        and first_order_joined.customer_id = orders.customer_id
        and first_order_joined.datetime = orders.created_at
    left join basket_size 
        on first_order_joined.order_id = basket_size.order_id
)

select * from order_features