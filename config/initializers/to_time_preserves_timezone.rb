# Be sure to restart your server when you modify this file.

# Preserve the timezone of the receiver when calling to `to_time`.
# Ruby 2.4 will change the behavior of `to_time` to preserve the timezone
# when converting to an instance of `Time` instead of the previous behavior
# of converting to the local system timezone.
#
# Rails 5.0 introduced this config option so that apps made with earlier
# versions of Rails are not affected when upgrading.
#
# Rails 8.0 deprecates setting `true` for the config option, from 8.1 `to_time`
# will always preserve the full timezone rather than the offset of the receiver.
ActiveSupport.to_time_preserves_timezone = :zone
