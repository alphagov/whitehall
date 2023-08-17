# Data migrations

## What they are and when to use them

Data migrations are generally used for code we want to run at or just after
deploy-time which either:
* requires interacting with another system, such as publishing-api or the search
  index
* depends on specific data being present in the database - for example, a third
  party running our code won't have access to a copy of our production data
* is a long-running data change which you want the flexibility to be able to run
  during quiet times

It is useful for them to be separate because developers and CI need to be able
to run normal migrations without requiring specific data in their database or to
have other services to be running.

The alternative is to write rake tasks which might be single use and/or might
require the right arguments to be documented separately from related code
changes.

They are implemented by reusing Rails' data migration code, but they have their
own rake task and database table for tracking which ones have been run.

## How to add one

There isn't currently a generator specifically for data migrations. The easiest way to
generate one is to generate a normal Rails migration using the command below and then
to move the new file to the `db/data_migration` directory.

```
  bundle exec rails g migration MyDataMigrationName
```

**N.B. This will not generate a valid data migration! Data migrations are just plain Ruby
scripts, not ActiveRecord migrations. Remove the contents of the generated migration before
you start writing code.**

Alternatively, you could manually create a new data migration and carefully name the file with
a correct leading timestamp.

## How to run them

Data migrations don't run automatically, they have to be run manually in all
environments.

### Development

Rake task:

```
  bundle exec rake db:data:migrate
```

or up to a specific version:

```
  bundle exec rake db:data:migrate VERSION=20140402115507
```

### At deploy time

We have a Jenkins job for convenience to save you having to ssh onto a box to
run the rake task. Here's the job on deploy.integration: [Run_Whitehall_Data_Migrations](https://deploy.integration.publishing.service.gov.uk/job/Run_Whitehall_Data_Migrations/)
