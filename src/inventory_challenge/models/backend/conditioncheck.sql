select 
    inventoryId as inventory_id,
    updatedAt as updated_at,
    JSON_VALUE(passed, 'status') as condition_check_passed,
    JSON_VALUE(passed, 'destination') as condition_check_detination,
    JSON_VALUE(passed, 'reason') as condition_check_failed_reason,
    row_number() over (partition by inventoryId order by updatedAt desc) = 1 as is_current
from "backend-v3"."conditionCheck"