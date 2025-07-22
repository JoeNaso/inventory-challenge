select
    id,
    name AS po_name,
    id AS po_id,
    updatedAt AS po_last_updated,
    dateStartExpected AS po_date_start_expected,
    dateEndExpected AS po_date_end_expected
from "backend-v3".purchaseOrders