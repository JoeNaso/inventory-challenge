select
    id,
    customer_id,
    reluvableId as reluvable_id,
    id AS reluvable_order_id,
    createdAt AS reluvable_created,
    state AS reluvable_status,
    payoutMethodId AS reluvable_payout_method,
    estimate AS reluvable_rev_estimate,
    age AS reluvable_age,
    condition AS reluvable_condition,
    JSON_VALUE(logisticsInfo, '$.city') AS reluvable_city,
    JSON_VALUE(logisticsInfo, '$.postal') AS reluvable_postal,
    JSON_VALUE(logisticsInfo, '$.province') AS reluvable_province,
    JSON_VALUE(logisticsInfo, '$.country') AS reluvable_country,
    JSON_VALUE(logisticsInfo, '$.tracking') AS reluvable_tracking_number,
    JSON_VALUE(logisticsInfo, '$.cost') AS reluvable_shipping_cost,
    logisticsInfo as logistics_infor

from "backend-v3".reluvableOrders