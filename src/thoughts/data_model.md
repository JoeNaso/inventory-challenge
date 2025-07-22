## Data Model

The data model in this repo is purely demonstrative, and certainly misses a few necessary details. But it is meant to illustrate some specific patterns: 

1. Different domains of data can be pre-processed before use in reporting
2. Well structured tables have utility outside of the final reporting table
3. Data can be processed incrementally (where is_current = True)

The `rpt_inventory_match` table is the final reporting table. This would be the output used by BI tools, accessible via RIMs or other applications, and serves as the "source of truth". It is a denormalized representation of it's component parts. 

However, we preprocess each of the those components parts so that we can manage processing data only as it need to be processed and preserve historical records without muddying the final output table. 

While `rpt_inventory_match` may be the primary access point, having well structured and testable tables that feed into that final output allow for consistent, composable inputs that Eng and Ops teams can use within other tools/ areas of the platform. 

This means we can have well-structured, validated and usable data throughout the warehouses, and allows us to construct "building blocks" that serve various use cases while maintaining consistency. This also lends itself to testing. 

## Testing
There are 3 main categories of testing:

1. Unit testing (referential integrity, uniqueness, accepted values, freshness etc)
2. Custom logical tests (written in sql)
3. Integration testing

Both 1 and 2 can be handled directly within the data modeling project (in this case, a dbt project). These tests can be configured at any point in the data lifecycle, and on any table or view. Referential integrity (ie. order.order_id exists within product.id) and uniqueness are the simplest yet most effective tests. We can also set freshness tolerances at the lowest level of table (models/backend/*.sql) to ensure our models are being built off data within our SLA. 

Custom logical tests are useful for asserting specific business logic that apply to our data. For instance, we may want to validate that liquidation deal values for a specific SKUs include a specific margin or that specific products are only available associated with specific warehouse aisles. 

Finally, integration testing is the most complex, but a requirement for platform migraitons. This often requires an orchestrator (or similar mechanism) but the overhead of setup is worth it when you can validate that systems match. This may be done by random sampling of output data in mutliple systems (RIMS vs BQ), full table parity (need to be smart about this given memory + compute constraints in RIMS). 

Data quality testing is critical but can often get unweildy. It's best to find the few patterns that address 80% of the issues and apply those patterns consistently across the platform, than look to implement incredibly complex validations from the start. You can always built in more tests, but over-indexing on testing can seriously slow down iteration early on. 

### Blue Green Deployments

A major benefit of programmatic testing beyond what's mentioned above is that we can modify the data model, deploy it, and generate resutls without impacting production data. Since the raw state of the data is stored in BQ in this example, we can build "ephemeral" instances of the project and compare that output to the current production. If a mismatch or error occurs, we can choose not to promote that change to production, and instead revisit the issue. 

There are numerous ways to make this happen but BQ Table Clones can be used to support "smart" release of changed tables without requiring reuiblding everything from scratch. 