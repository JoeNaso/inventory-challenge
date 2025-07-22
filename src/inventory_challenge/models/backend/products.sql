select
    id,
    id as RI,
    brandId as brand_id,
    categoryId as category_id,
    currency AS product_currency,
    value AS product_compare_at_price,
    updatedAt AS product_last_updated,
    GTIN AS product_gtin,
    cost as product_fallback_cost
from "backend-v3".products
