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

## Running linters locally

Once you have the gems running you can run the ruby and javascript linters without using docker:

```
bundle exec rake lint
```

This is a good idea before pushing, unless you have an IDE that checks linters, or you have run a full test suite (which also runs them inside docker)

## Running an individual test file

```
govuk-docker-run bundle exec rake test TEST=path/to/test/file
```

```
govuk-docker-run cucumber path/to/cucumber/test
```

## Changing local user permissions / flags

User permissions double in some cases as feature flags - see [Permissions in the User model](https://github.com/alphagov/whitehall/blob/main/app/models/user.rb#LL16C7-L16C7) for valid permission values

So if you want to view the next release UI, you need to be logged in as a user with the "Preview next release" permission.

To change permissions on a dev machine, run the following to open a rails console:

```bash
govuk-docker run whitehall-lite rails console
```

In development you are logged in as the first user - in the console you can find that user and see their permissions:

```rb
> user = User::first()
> user.permissions
 ["Editor", "GDS Editor", "Import CSVs", "signin"]
```

You can, for example, add the "Preview next release" permission as follows:

```rb
> user = User::first()
> user.permissions <<= User::Permissions::PREVIEW_NEXT_RELEASE
> user.save!
```

Similarly you can remove permissions by removing them from user.permissions:

```rb
> user = User::first()
> user.permissions.reject! { |p| p == User::Permissions::PREVIEW_NEXT_RELEASE }
> user.save!
```

If you reload a Whitehall page in your browser, the new permissions should be used immediately.
