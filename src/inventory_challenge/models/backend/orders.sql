select
    id,
    o.shopifyOrderId AS shopify_order_id,
    o.createdAt AS shopify_order_fulfilled_date,
    o.updatedAt AS order_last_updated
from "backend-v3".orders