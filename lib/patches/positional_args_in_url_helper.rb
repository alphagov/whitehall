# There is a bug in Rails that causes a default :format to be lost when there
# are multiple positional args in the routing, for example:
#
#   "/topics/:id(.:format)"
#
# This manifests itself in `Whitehall.atom_feed_maker`, which sets the default
# format to "atom".
#
# This patches Rails to fix the issue. There is a pull request on Rails to fix
# the issue[1]. Once that is merged (and/or backported to the version of Rails
# Whitehall is using), this patch can be removed.
#
# Note that this also backports another bug fix that has not been backported to
# Rails 4.0 stable [2]
#
# [1]: https://github.com/rails/rails/pull/18627
# [2]: https://github.com/rails/rails/pull/18020
module PatchPositionalRoutingArgumentHandling
  def handle_positional_args(t, args, options, keys)
    inner_options = args.extract_options!
    result = options.dup

    if args.size > 0
      # take format into account
      if keys.include?(:format)
        keys_size = keys.size - 1
      else
        keys_size = keys.size
      end

      if args.size < keys_size
        keys -= t.url_options.keys if t.respond_to?(:url_options)
        keys -= options.keys
      end

      keys -= inner_options.keys
      keys.take(args.size).each do |key|
        result[key] = args.shift
      end
    end

    result.merge!(inner_options)
  end
end

class ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper
  prepend PatchPositionalRoutingArgumentHandling
end
