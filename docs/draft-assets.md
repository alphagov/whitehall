Draft assets for 'migrated' formats
===================================

Edition based formats have all now been 'migrated' and are rendered by 
'government-frontend'. Assets however, are still stored and served from the 
`whitehall-frontend-*` servers. The assets themselves are stored in an NFS mount
linked into the `/public/government/assets/` directory within the Whitehall app 
on these boxes (and on `whitehall-backend-*`).

Requests for an asset from published content (www-origin.<env>) go:

lb -> cache -> router -> (via the `/government` prefix route) -> whitehall-frontend-\* -> asset gets served

Requests for an asset for draft content (draft-origin.<env>) go:

lb -> cache -> router -> (via the `/government/assets` prefix route -> whitehall-frontend-\* -> asset gets served

The prefix route `/government` in the draft router previously
sent the request to `draft-whitehall-frontend-*`. This does not really 'exist' as an app
but is present on the `whitehall-backend-*` boxes as an nginx host.
That host does not have a `location` for `/government/assets` or the correct `root` so
the asset is not served. It is also on a backend box which is confusing.

A slightly more correct approach would be to have draft-whitehall-frontend exist
on the `whitehall-frontend-*` boxes and serve assets from there but this is still 
confusing as it alludes to there being a draft version of Whitehall which there isn't.

Future work on assets will address this but until then the addition of these
routes to the draft router was the less complex of two bad solutions. 
