select
    id,
    MSRP,
    MSRP as po_compare_at_price,
    purchaseOrderId as po_id,
from "backend-v3".lineItems