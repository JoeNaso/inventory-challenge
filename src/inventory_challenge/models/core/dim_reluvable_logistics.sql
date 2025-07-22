select

    r.reluvable_id,
    rl.reluvable_order_id,
    rl.reluvable_created,
    rl.reluvable_status,
    r.reluvable_company,
    rl.reluvable_payout_method,
    rl.reluvable_rev_estimate,
    rl.reluvable_age,
    rl.reluvable_condition,
    rl.reluvable_city,
    rl.reluvable_postal,
    rl.reluvable_province,
    rl.reluvable_country,
    rl.reluvable_tracking_number,
    rl.reluvable_shipping_cost,
    rl_cu.reluvable_customer_id,
    rl_cu.reluvable_customer_name,
    rl_cu.reluvable_customer_email,

FROM {{ ref('reluvable_orders') }} rl
LEFT JOIN {{ ref('reluvable') }} r
    ON r.id = rl.reluvable_id
LEFT JOIN {{ ref('customers') }} rl_cu
    ON rl.customer_id = rl_cu.id

