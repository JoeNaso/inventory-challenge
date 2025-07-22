select
    warehouses.warehouse_name,
    warehouses.warehouse_id,
    warehouses.warehouse_last_updated,
    bin.bin_name,
    bin.bin_id,
    bin.bin_last_updated,
    aisles.aisle_name,
    aisles.aisle_id,
    aisles.aisle_last_updated,
    regions.region_name,
    regions.region_id,
    regions.region_currency,
    regions.region_last_updated,
FROM {{ ref('bin') }} bin
LEFT JOIN  {{ ref('aisles') }} aisles
    on bin.asile_id = aisles.id
LEFT JOIN {{ ref('warehouses') }} warehouses
    on aisles.warehouse_id = warehouses.id
LEFT JOIN {{ ref('regions') }} regions
    on warehouses.region_id = regions.id
