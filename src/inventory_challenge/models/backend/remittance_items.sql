 SELECT 
    inventory_id, 
    SUM(amount) as amount
 FROM "backend-v3".remittance_items
 GROUP BY inventory_id