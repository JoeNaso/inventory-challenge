## Potentially Committed Items
There are a two components to the current design that can be improved:
1. BQ directly reading from CloudSQL Postgres
2. Rebuilding _everything_ in the reporting table


### BQ directly reading from CloudSQL
While convenient, this patterns the door for a number of issues. It also artifically restricts the performance of the entire platform.

If you're using BigQuery's federated queries to CloudSQL, I suggest you move off of this. It increases load on your CloudSQL istance and will directly consume RAM and CPU on that. This means degraded perfoamnce for RIMS, not to mention the performance of analytical workloads is contrained by tuning CloudSQL accordingly. We should isolate transactional worklods and analytical workloads. 

If you are not using this federated pattern, and are instead replicaitng the final table BQ, we should look to build out thisimplementation appropriately. 

There are various alternatives to this access pattern, both vendor and in-house. Estuary.dev is a great vendor option. This can also be managed in-house using GCP's DataStream product. There are many other options (Fivetran, etc), though some can get VERY expensive. 

This change in data loading allows us to implement more performant data models in the warehouse, too. And gives the added bonus of introducing separate "stages" of data processing, where we can apply data quality checks and tests.


### Rebuilding _everything_
We should be able to remove this operation altogether.

First, we need to model this data appropriately so we are trimming both the number of tables and scope of data being processed at the last stage (final table creation/ update). 

As an example, if the RIMS application knows about shopify details for a specific item as soon as it enters the warehouse, we can persist a representation of all relevant product and brand details for quick access downstream. If these details are slow-changing, even better. We  only have to update the tables in the warehouse as new data comes in. By processing these many tables into meaningful dimensions and facts, we can reduce the footprint of our final output table from 15 joins to ~5 or so. 

This simplifies access points for reporting (few tables) and presents the data in a business-friendly structure. 

We can work towards this reality by breaking the entire processing pipeline into different tiers of data. Roughly:
- Raw
- Core
- Analytics (or Reporting)

The Raw layer can act as the "landing zone" for all inbound data. Core represents a set of meaningful, validated dimensions and various denormalized tables that are ready for use. The Analytics layer is what is exposed in reports. If you separate the tables in this way, you naturally gate release of bad data into the next stage/ tier. It also allows us to pre-process data appropriately at each stage in order to reduce (and ideally eliminate) the need to rebuild everything. 

The default behavior for ingesting and processing data should be incremental; this may be the case in RIMS, but it doesn't necessarily seem to be the case for the current BigQuery setup. From a reporting perspective, we care about "now". Incremental ingestion and building incremental data models allows us to maintain a historical record AND a current state. 

For the core question of "is this item committed", we only need to reprocess the *latest* state change (ie new data). If an item is committed and no new data corresponding to that item has appeared, we don't need to reprocess. If new data does appear - regardless of whether that state change is a fulfillment, cancellation, or something else - we can use that to reflect the current state. From an implementation perspective, this essentially translates to `MERGE` statements. 

We want performant queries at the raw data processing, which likely means using partitioning and clustering configurations at various points in the pipeline.


### Potentially Committed Items
Our goal should be to do as little work as possible to show the current state, both in RIMS and in BigQuery. RIMS already knows what that state is, but rebuilding everything in order to present an aggregate view of that state is very costly. 

There are a number of ways to do this, but depending on the SLA, we can introduce some event processing patterns to solve address consistency and timeliness of updates. 

**Option 1:**
When updating the state of an item in RIMS, we an use an Outbox pattern to both update the transactional DB AND emit an event to GCP Pub/Sub. This reasonably address consistency. We can subscribe BigQuery to these Pub/Sub events and persist the them to BQ without replcating directly from Postgres. This table should be partitioned by some datetime value; the partitioning depends on throughput of events (ie. daily vs hourly). Additionally, we can cluster in this table by some meaning value (possibly order_id or similar) to enable faster pruning for downstream queries. 

We will resolve this incoming data to the "current known state" of that item based on the newly ingested events. These can also work as MERGE/ UPDATE statements which run on some pre-defined schedule. In order to ensure we dont miss any late-arriving facts, we can make sure each MERGE execution is using a lookback period (ie. multiple partitions). This introduces a small amount of additional work, with the intention being not missing any changes. 

As changes accumulate, the BQ representation of the data is kept in-sync according to the incoming events. The rest of the transformations run at their normally scheduled cadence, and we propagate the "potentially Comitted" status to the reporting layer. 

**Option 2:**
We can mimic this behavior using GCP DataStream, which provides change-data-capture from your CloudSQL instance into BigQuery. Fundamentally, the workflow is the same, but the mechanism for "capturing" these state changes is different. 

This approach differs in that we persist every change at the DB level, not just those we deem critical/ worthy of the eventing pattern in Option 1. DataStream is a great tool, but can get expensive if not properly tuned and controlled. 

The resolution of the "potentially committed status" and various downstream transformations would work much the same as Option 1. 

