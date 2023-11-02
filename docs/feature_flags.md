# Feature Flags

Feature flags in Whitehall are managed using the [FlipFlop gem](https://github.com/voormedia/flipflop). The gem is currently
configured so that only the ActiveRecord and default strategies are active.

## Toggling Feature Flags

In local development environments, a UI is available to make it easy to toggle feature flags on and off during development.
The UI can be accessed at http://whitehall-admin.dev.gov.uk/flipflop. To toggle feature flags in non-local environments, the
rake task provided by FlipFlop can be used, e.g.

```bash
bundle exec rake flipflop:turn_on[new_feature,active_record]   # Enables the new feature with the Active Record strategy
bundle exec rake flipflop:turn_off[new_feature,active_record]  # Disables the new feature with the Active Record strategy
```

## Testing with Feature Flags

Feature flags are made accessible via the [`feature_flags`] helper on `ActionController::TestCase`.

To toggle a feature flag in your controller test:

```ruby
feature_flags.switch! :your_feature, true
```