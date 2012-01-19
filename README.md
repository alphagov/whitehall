# Whitehall App

## Using local assets

* Set `SLIMMER_ASSET_HOST` to point to your local instance of the `static` app when running the `whitehall` app e.g. `SLIMMER_ASSET_HOST=http://static.dev`

## Getting search running locally

The Whitehall app relies on a separate instance of [Rummager](https://github.com/alphagov/rummager) for document search. The default (citizen) configuration is overridden by the `whitehall-rummager` project in the deployment repository.

To use a local copy of Rummager you'll need to:

* Tell Rummager to use the whitehall solr core by setting `:path: "/solr/whitehall-rummager"` in `rummager/solr.yml`.
* Tell Rummager to listen for requests on the whitehall prefix by setting `:path_prefix: "/government"` in `rummager/router.yml`.
* Set `RUMMAGER_HOST` to point to the local instance of Rummager (e.g. `export RUMMAGER_HOST=http://rummager.dev` in `.powrc`).
* You'll also need to set `RUMMAGER_HOST` when using the Rummager rake tasks e.g. `RUMMAGER_HOST=http://rummager.dev rake rummager:index`.
* Optional: if you want to hit the Rummager app directly from a browser (i.e. not using `Accept: application/json`), e.g. to see how the citizen app works, then you may want to set `SLIMMER_ASSET_HOST` to point to your local instance of the `static` app.

To use a local copy of Solr you'll need to:

* Install Solr using e.g. `brew install solr`.
* Change the `dataDir` in `alphagov-puppet/puppet/modules/solr/files/etc/solr/whitehall-rummager/conf/solrconfig.xml` to point to somewhere suitable and create the directory so that the Solr process will have permission to write files.
* Within the deployment respository, remove all cores other than `whitehall-rummager` from `alphagov-puppet/puppet/modules/solr/files/solr.xml` and change the two `instanceDir` values for the `whitehall-rummager` core to point to the actual location on your file system i.e. `alphagov-puppet/puppet/modules/solr/files/etc/solr/whitehall-rummager`.
* Tell Rummager to send requests to your local Solr instance by setting `:server: localhost`, `:path: "/solr/rummager"` & `:port: 8983` (these are the defaults).
* Run your local Solr instance using: `solr path/to/solr.xml` i.e. something ending in `alphagov-puppet/puppet/modules/solr/files`.
* If this is a new install of Solr, you'll need to run the `rummager:index` rake task (described above) from within the `whitehall` app before you will get any search results.