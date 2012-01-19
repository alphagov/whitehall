# Whitehall App

## Using local assets

* Set `STATIC_DEV` to point to your local instance of the `static` app when running the `whitehall` app e.g. `STATIC_DEV=http://static.dev`

## Getting search running locally

The Whitehall app relies on a separate instance of [Rummager](https://github.com/alphagov/rummager) for document search. The default (citizen) configuration is overridden by the `whitehall-rummager` project in the deployment repository.

To use a local copy of Rummager you'll need to:

* Tell Rummager to use the whitehall Solr core by setting `:path: "/solr/whitehall-rummager"` in `rummager/solr.yml`.
* Tell Rummager to listen for requests on the whitehall path prefix by setting `:path_prefix: "/government"` in `rummager/router.yml`.
* Set `RUMMAGER_HOST` to point to the local instance of Rummager (e.g. `export RUMMAGER_HOST=http://rummager.dev` in `.powrc`).
* You'll also need to set `RUMMAGER_HOST` when using the Rummager rake tasks e.g. `RUMMAGER_HOST=http://rummager.dev rake rummager:index`.
* Optional: if you want to hit the Rummager app directly from a browser (i.e. not using `Accept: application/json`), e.g. to see how the citizen app works, then you may want to set `SLIMMER_ASSET_HOST` to point to your local instance of the `static` app.

To use a local copy of Solr - see the instruction in the Rummager [README.md](https://github.com/alphagov/rummager).