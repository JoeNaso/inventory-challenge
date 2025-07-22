SELECT
    id,
    line_items AS items,
    created_at,
    cancelled_at,
    order_number,
    referring_site,
    payment_gateway_names,
    fulfillments,
    shipping_address
FROM "shopify_proxy".orders
