# Tips for working on whitehall locally

## Installing Whitehall gems locally

Sometimes it’s useful to install Whitehall on bare metal, outside of the standard `govuk-docker` environment.

Annoyingly, just running `bundle install` can result in an error where it fails to install the `mysql2` gem. It tries to build it but fails when it can’t find some required system libraries.

### This can be resolved by:

1. `brew install mysql2 openssl@3`
2. Add the following to `~/.bundle/config`:

```jsx
BUNDLE_BUILD__MYSQL2: "--with-opt-dir=/opt/homebrew/opt/openssl@3 --with-ldflags=-L/opt/homebrew/Cellar/zstd/1.5.2/lib"
```

1. `bundle install` should now succeed.

**Note:** this assumes you’re on an M1 Mac, where `brew --prefix` is `/opt/homebrew`. The paths will be different on Intel Macs, but hopefully the logic is the same.
