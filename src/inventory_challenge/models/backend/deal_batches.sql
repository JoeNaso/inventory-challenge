select
    id,
    warehouseId as warehouse_id,
    id AS deal_batch_id,
    name AS deal_batch_name,
    status AS deal_batch_status,
    dateExpected AS deal_batch_date_expected,
    receivedAt as deal_batch_date_received,
    warehouseId AS deal_batch_warehouse_id,
    name AS deal_batch_warehouse_name,
    dateExpected AS deal_unit_batch_date_expected,
    receivedAt as deal_unit_batch_date_received
from "backend-v3".warehouses