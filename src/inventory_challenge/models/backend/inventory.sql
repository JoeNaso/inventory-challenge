select
    id,
    id as rin,
    state,
    condition AS inventory_condition,
    dateStocked AS date_stocked,
    dateEgressed AS date_egressed,
    deletedAt as deleted_at,
    soldDate AS inventory_sold_date,
    soldFor AS inventory_sold_for,
    cost as inventory_cost,
    updatedAt AS inventory_last_updated,
    lineItemId as line_item_id,
    owner as inventory_owner,
    productId as product_id,
    orderId as order_id,
    vendorId as vendor_id,
    binId as bin_id,
    cast(shopifyVariantId as text) as shopify_variant_id,
    reluvableOrderId as reluvable_order_id
    dateEgressed is not null as did_egress,
    ancillary,
    JSON_VALUE(ancillary, '$.egress') as ancillary_egress,
    JSON_VALUE(ancillary, '$.egress.destination') as ancillary_egress,
    JSON_VALUE(ancillary, '$.egress.destination') is null as has_ancillary_egress_destination
    

from "backend-v3".inventory


 CASE
 WHEN i."dateEgressed" NOTNULL AND i."soldDate" NOTNULL AND i.ancillary-
>'egress'->>'destination' ISNULL THEN 'Sell'
 WHEN i."dateEgressed" NOTNULL AND i.ancillary->'egress'->>'destination' =
'Liquidation' THEN 'Clearance'
 WHEN i."dateEgressed" NOTNULL AND i.ancillary->'egress'->>'destination'
NOTNULL THEN i.ancillary->'egress'->>'destination'
 ELSE NULL
 END AS "final_disposition",