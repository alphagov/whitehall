# Migration sync checks

As part of the migration process a 'sync check' is created for each format.
This allows us to test that the content-store representation of a content item
is in the correct state prior to switching rendering over from whitehall to
government-frontend.

## Creating a sync check 

In general this involves the creation of a format specific file within
lib/sync_checker/formats. A sync check specifies tests that should run against
the live content store and tests that should run against the draft content
store. There are existing checks that can be used as a basis for subsequent
formats. There is also an `EditionBase` class that covers most of the checks
for `Edition` based content.

## Running the sync checks 

There is a runner that allows the checks to be run
from the console with the format:

`bundle exec rails runner script/run_sync_checks Publication --output tmp/results.csv`

This will run the checks for all `Publication`s and output the results to
`tmp/results.csv`. The output file is optional.

The runner accepts the following arguments:

`-i` allows a comma separated string of ids to be supplied

e.g `bundle exec rails runner script/run_sync_checks -i 1234,1235,1236 Publication `

`-f` will check the last failures (stored in `tmp/.sync_check_failures`)

`-r` will republish (optionally `-ri 1234,1235` to specify ids) This should
not be used for large numbers of documents as it is synchronous and will
timeout from time to time making results unreliable.

## On integration/staging/production

To run on an environment other than the dev VM the correct env needs to be
set up

`sudo -u deploy govuk_setenv whitehall bundle exec rails runner script/run_sync_checks Publication`

Generally this should be run in a `screen` or `tmux` session as they can take a
while to complete for the larger formats.

## Automatically queued checks

All content that is sent to publishing API now queues a check to run 5 minutes
after the changes are saved. The results of these checks are saved in the
`sync_check_results` table and will be used in the future for ongoing
monitoring.
