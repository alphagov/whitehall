# Whitehall App

## Getting search running locally

The Whitehall app relies on [Rummager](https://github.com/alphagov/rummager) for document search.

To use a local copy of Rummager you'll need to:

* Tell rummager to use the whitehall solr core by setting `:path: "/solr/whitehall-rummager"` in rummager/solr.yml.
* Tell rummager to listen for requests on the whitehall prefix by setting `:path_prefix: "/government"` in rummager/router.yml.
* Set RUMMAGER_HOST to point to the local copy of rummager (e.g. `export RUMMAGER_HOST=http://rummager.dev` in .powrc).

*NOTE* "Autocomplete" won't work locally.