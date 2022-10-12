with order_line as ( select * from {{ source('shopify_tables', 'order_line') }} ),

basket_size as ( 
    select 
        order_id,
        sum(quantity) as basket_size

    from order_line
    group by 1
)

select * from basket_size 
