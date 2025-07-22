select
    p.id,
    p.RI,
    p.brand_id,
    p.category_id,
    p.product_currency,
    p.product_compare_at_price,
    p.product_last_updated,
    p.product_gtin,
    p.product_fallback_cost,
    b.product_brand_name,
    b.product_brand_id,
    b.brand_last_updated
from {{ ref('products') }} p
left join {{ ref('brands') }} b
    on p.brand_id = b.product_brand_id
