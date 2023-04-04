Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices


### A comment about partitioning and clustering

Depending on what we want to query, it might be we would partition and cluster with opposite columns.

If we want to track a vessel location (where mmsi = ) we should partition by mmsi (vessel id) and cluster by date (order by timestamp)
But we would still probably want to filter the date as well? To track a vessel within certain limits.

If we want to know the big picture at certain time (where timestamp = ) we should partition by timestamp and cluster by mmsi (order by mmsi/vessel id).

There are probably more than 4000 distinct mmsi, therefor partitioning on timestamp makes sense.
However, when we partition on an integer we decide min, max and step. Which makes it possible to add several mmsi in the same partition. ....

## dbt incremental table

Makes sense?
In one year we have about 1 TB
Will only add data that is newer than existing data.

If loading old data, have to either [rebuild whole](https://docs.getdbt.com/docs/build/incremental-models#how-do-i-rebuild-an-incremental-model) or consider changing the if statement to include data that with timestamp older than the existing table (will not work for data with timestamp in between existing data).
Usefull information:
https://docs.getdbt.com/docs/build/incremental-models
