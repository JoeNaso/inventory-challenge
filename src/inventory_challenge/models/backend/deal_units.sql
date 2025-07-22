select 

    title AS deal_unit_title,
    cost AS deal_unit_cost,
    msrp AS deal_unit_msrp,
    age AS deal_unit_age,
    condition AS deal_unit_condition,
    og_ref AS deal_unit_og_ref,
    aka_barcode AS deal_unit_aka_barcode,
    createdAt AS deal_unit_created_at,
    dealBatchId as deal_batch_id,
    inventoryId as inventory_id
    
from "backend-v3".deal_units
