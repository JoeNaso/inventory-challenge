SELECT
    id AS inventory_vendor_id,
    name AS inventory_vendor,
    updatedAt AS vendor_last_updated,
    shopifyVendorId as inventory_vendor_shopify_identifier
from "backend-v3".vendors