select

    d.deal_id,
    d.deal_name,
    d.deal_direct,
    d.deal_owner,
    d.deal_currency,
    dv.deal_vendor_name,
    dv.deal_vendor_id,
    dba.deal_batch_id,
    dba.deal_batch_name,
    dba.deal_batch_status,
    dba.deal_batch_date_expected,
    dba.deal_batch_date_received,
    dba.deal_batch_warehouse_id,
    dbaw.deal_batch_warehouse_name,
    dba.deal_unit_batch_date_expected,
    dba.deal_unit_batch_date_received,
    du.deal_unit_title,
    du.deal_unit_cost,
    du.deal_unit_msrp,
    du.deal_unit_age,
    du.deal_unit_condition,
    du.deal_unit_og_ref,
    du.deal_unit_aka_barcode,
    du.deal_unit_created_at,

FROM {{ ref('deal') }} d
LEFT JOIN  {{ ref('deal_units') }} du
    on du.deal_id = d.id
LEFT JOIN {{ ref('deal_batches') }} dba
    on du.deal_batch_id = dba.id
