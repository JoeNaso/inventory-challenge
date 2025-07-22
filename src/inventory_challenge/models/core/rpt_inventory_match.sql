with liquidation_deal_details as (
    select
        * 
    from {{ ref('liquidation_deal_details') }}
),

dim_product_detail as (
    select
        * 
    from {{ ref('dim_product_details') }}
    where is_current = True
),

dim_product_location as (
    select
        *
    from {{ ref('dim_product_location') }}
    where is_current = True
),

dim_reluvable_logistics as (
    select 
        *
    from {{ ref('dim_reluvable_logistics') }}
    where is_current = True
)

-- Actual Join conditions are demonstrative, not necessarily correct for this exmaple
-- Additionally, real-world queries would always specify columns
select

    liquidation_deal_details*,
    dim_product_detail.*,
    dim_product_location.*,
    dim_reluvable_logistics.*

from liquidation_deal_details
left join dim_product_detail
    on liquidation_deal_details.product_id = dim_product_detail.product_id
left join dim_product_location
    on dim_product_detail.product_id = dim_product_location.product_id
left join dim_reluvable_logistics 
    on liquidation_deal_details.purchase_order_id = dim_reluvable_logistics.purchase_order_id