WITH remittances AS (
 SELECT inventory_id, SUM(amount) amount
 FROM "backend-v3".remittance_items
 GROUP BY inventory_id
),
inventory AS (
 SELECT * FROM "backend-v3".inventory
),
deal_units AS (
 SELECT * FROM "backend-v3".deal_units
),
orders AS (
 SELECT * FROM "backend-v3".orders
),
latest_condition_checks AS (
 SELECT * FROM (
 SELECT *,
 ROW_NUMBER() OVER (PARTITION BY "inventoryId" ORDER BY "updatedAt"
DESC) AS row_num
 FROM "backend-v3"."conditionCheck"
 ) AS lcc_i WHERE row_num = 1
),
shopify_proxy as (
 SELECT (variant->>'id')::BIGINT AS variant_id, variant, tags, vendor
 FROM "backend-v3"."PROXY_shopifyProducts"
)
SELECT
-- ID Information
 i.id AS "RIN",
 p.id AS "RI",
-- State Information
 i.state AS "state",
 i.condition AS "inventory_condition",
 i."dateStocked" AS "date_stocked",
 i."dateEgressed" AS "date_egressed",
 i."deletedAt",
 i."soldDate" AS "inventory_sold_date",
 i."soldFor" AS "inventory_sold_for",
 i."updatedAt" AS "inventory_last_updated",
 CASE
 WHEN i."dateEgressed" NOTNULL AND i."soldDate" NOTNULL AND i.ancillary-
>'egress'->>'destination' ISNULL THEN 'Sell'
 WHEN i."dateEgressed" NOTNULL AND i.ancillary->'egress'->>'destination' =
'Liquidation' THEN 'Clearance'
 WHEN i."dateEgressed" NOTNULL AND i.ancillary->'egress'->>'destination'
NOTNULL THEN i.ancillary->'egress'->>'destination'
 ELSE NULL
 END AS "final_disposition",
-- Physical Location Information
 wh.name AS "warehouse_name",
 wh.id AS "warehouse_id",
 wh."updatedAt" AS "warehouse_last_updated",
 bin.name AS "bin_name",
 bin.id AS "bin_id",
 bin."updatedAt" AS "bin_last_updated",
 als.name AS "aisle_name",
 als.id AS "aisle_id",
 als."updatedAt" AS "aisle_last_updated",
 reg.name AS "region_name",
 reg.id AS "region_id",
 reg.currency AS "region_currency",
 reg."updatedAt" AS "region_last_updated",
-- Product Details & Category
 p.title AS "product_title",
 p.currency AS "product_currency",
 p.value AS "product_compare_at_price",
 p."updatedAt" AS "product_last_updated",
 p."GTIN" AS "product_gtin",
 c.name AS "category_name",
 c.id AS "category_id",
 c."updatedAt" AS "category_last_updated",
 c.vertical AS "category_vertical",
-- Brand Details
 b.name AS "product_brand_name",
 b.id AS "product_brand_id",
 b."updatedAt" AS "brand_last_updated",
-- Shopify Order and Listing Information
 sp.title AS "rims_storefront_product_title",
 o."shopifyOrderId" AS "shopify_order_id",
 o."createdAt" AS "shopify_order_fulfilled_date",
 o."updatedAt" AS "order_last_updated",
 i."shopifyVariantId" AS "shopify_variant_id",
 sv.variant->>'price' AS "shopify_price",
 sv.variant->>'compare_at_price' AS "shopify_compare_at_price",
 sv.variant->>'sku' AS "shopify_sku",
 sv.variant->>'inventory_item_id' AS "shopify_inventory_id",
 sv.variant->>'barcode' AS "shopify_barcode",
 sv.vendor AS "shopify_vendor",
 sv.tags AS "shopify_tags",
 sf.domain AS "storefront_domain",
 sf.id AS "storefront_id",
-- Purchasing & Cost Information
 po.name AS "po_name",
 po.id AS "po_id",
 po."updatedAt" AS "po_last_updated",
 po."dateStartExpected" AS "po_date_start_expected",
 po."dateEndExpected" AS "po_date_end_expected",
 li."MSRP" AS "po_compare_at_price",
 v.name AS "inventory_vendor",
 v.id AS "inventory_vendor_id",
 v."updatedAt" AS "vendor_last_updated",
 i.cost AS "inventory_cost",
 p.cost AS "product_fallback_cost",
-- Vendors Info
 v."shopifyVendorId" AS "inventory_vendor_shopify_identifier",
-- Purchase and Order Information
 i."soldFor" AS "inventory_sold_for",
 i."soldDate" AS "inventory_date_sold",
-- Custom Receive Information
 cr."createdAt" AS "custom_receive_created",
 cr.title AS "custom_receive_title",
-- Reluvable Information
 r.id AS "reluvable_id",
 rl.id AS "reluvable_order_id",
 rl."createdAt" AS "reluvable_created",
 rl.state AS "reluvable_status",
 r.company AS "reluvable_company",
 rl."payoutMethodId" AS "reluvable_payout_method",
 rl.estimate AS "reluvable_rev_estimate",
 rl.age AS "reluvable_age",
 rl.condition AS "reluvable_condition",
 rl."logisticsInfo"->>'city' AS "reluvable_city",
 rl."logisticsInfo"->>'postal' AS "reluvable_postal",
 rl."logisticsInfo"->>'province' AS "reluvable_province",
 rl."logisticsInfo"->>'country' AS "reluvable_country",
 rl."logisticsInfo"->>'tracking' AS "reluvable_tracking_number",
 rl."logisticsInfo"->>'cost' AS "reluvable_shipping_cost",
 rl_cu.id AS "reluvable_customer_id",
 rl_cu.name AS "reluvable_customer_name",
 rl_cu.email AS "reluvable_customer_email",
-- Liquidation deal information
 d.id AS "deal_id",
 d.name AS "deal_name",
 d.direct AS "deal_direct",
 d.ownership AS "deal_owner",
 d.currency AS "deal_currency",
 dv.name AS "deal_vendor_name",
 dv.id AS "deal_vendor_id",
 dba.id AS "deal_batch_id",
 dba.name AS "deal_batch_name",
 dba.status AS "deal_batch_status",
 dba."dateExpected" AS "deal_batch_date_expected",
 dba."receivedAt" as "deal_batch_date_received",
 dba."warehouseId" AS "deal_batch_warehouse_id",
 dbaw.name AS "deal_batch_warehouse_name",
 dba."dateExpected" AS "deal_unit_batch_date_expected",
 dba."receivedAt" as "deal_unit_batch_date_received",
 du.title AS "deal_unit_title",
 du.cost AS "deal_unit_cost",
 du.msrp AS "deal_unit_msrp",
 du.age AS "deal_unit_age",
 du.condition AS "deal_unit_condition",
 du.og_ref AS "deal_unit_og_ref",
 du.aka_barcode AS "deal_unit_aka_barcode",
 du."createdAt" AS "deal_unit_created_at",
-- Owner Information
 i.owner AS "inventory_owner",
-- Condition Check
 cc.passed->>'status' AS "condition_check_passed",
 cc.destination AS "condition_check_destination",
 cc.passed->>'reason' AS "condition_check_failed_reason",
 rem.amount AS "remittance_total"
FROM inventory i
 LEFT OUTER JOIN "backend-v3".products p ON i."productId" = p.id
 LEFT OUTER JOIN "backend-v3".brands b ON p."brandId" = b.id
 LEFT OUTER JOIN orders o ON i."orderId" = o.id
 LEFT OUTER JOIN "backend-v3".categories c ON p."categoryId" = c.id
 LEFT OUTER JOIN "backend-v3"."lineItems" li ON i."lineItemId" = li.id
 LEFT OUTER JOIN "backend-v3"."purchaseOrders" po ON li."purchaseOrderId" =
po.id
 LEFT OUTER JOIN "backend-v3".vendors v ON i."vendorId" = v.id
 LEFT OUTER JOIN "backend-v3"."storefrontProducts" sp ON
i."shopifyVariantId"::TEXT = sp."shopifyVariantId"
 LEFT OUTER JOIN "backend-v3"."storefront" sf ON sp."storefrontId" = sf.id
 LEFT OUTER JOIN "backend-v3".bins bin ON i."binId" = bin.id
 LEFT OUTER JOIN "backend-v3".aisles als ON als.id = bin."aisleId"
 LEFT OUTER JOIN "backend-v3".warehouses wh ON wh.id = als."warehouseId"
 LEFT OUTER JOIN "backend-v3".regions reg ON wh."regionId" = reg.id
 LEFT OUTER JOIN shopify_proxy sv ON i."shopifyVariantId" = sv.variant_id
 LEFT OUTER JOIN "backend-v3"."customReceive" cr ON cr.id = i."customReceiveId"
 LEFT OUTER JOIN "backend-v3"."reluvableOrders" rl ON rl.id = 
i."reluvableOrderId"
 LEFT OUTER JOIN "backend-v3"."customers" rl_cu ON rl_cu.id = rl."customerId"
 LEFT OUTER JOIN "backend-v3"."reluvable" r ON r.id = rl."reluvableId"
 LEFT OUTER JOIN deal_units du on du."inventoryId" = i.id
 LEFT OUTER JOIN "backend-v3"."deal_batches" dba on dba.id = du."dealBatchId"
 LEFT OUTER JOIN "backend-v3".warehouses dbaw on dbaw.id = dba."warehouseId"
 LEFT OUTER JOIN "backend-v3".deals d ON du."dealId" = d.id
 LEFT OUTER JOIN "backend-v3".vendors dv ON dv.id = d."vendorId"
 LEFT OUTER JOIN latest_condition_checks cc ON cc."inventoryId" = i.id
 LEFT OUTER JOIN "remittances" rem ON i.id = rem.inventory_id
ORDER BY i.id DESC;