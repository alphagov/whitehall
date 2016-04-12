# Assets

Ideally, you will have a copy of
[`static`](https://github.com/alphagov/static) running locally (at http://static.dev.gov.uk by default) 
and that will be used to serve shared assets. This is how things will work by default if you
are running the GOV.UK development VM with `foreman` or `bowler`.

If you are running Whitehall with `bundle exec rails server` and don't want to
run a local copy of `static`, you can tell the app to use assets served
directly from the Integration environment by setting `STATIC_DEV`:

```
STATIC_DEV=https://assets-origin.integration.publishing.service.gov.uk/ bundle exec rails server
```

If you are only working on the Whitehall admin interface, you don't need the
assets available.
