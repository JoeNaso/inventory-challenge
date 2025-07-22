select
    CAST(JSON_VALUE(variant '$.id') as NUMERIC) as variant_id,
    tag as shopify_tags,
    vendor as shopify_vendor
    JSON_VALUE(variant, '$.price') AS "shopify_price",
    JSON_VALUE(variant, '$.compare_at_price') AS "shopify_compare_at_price",
    JSON_VALUE(variant, '$.sku') AS "shopify_sku",
    JSON_VALUE(variant, '$.inventory_item_id') AS "shopify_inventory_id",
    JSON_VALUE(variant, '$.barcode') AS "shopify_barcode",
    variant
from "backend-v3".PROXY_shopifyProducts