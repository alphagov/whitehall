module FriendlyId
  module CustomNormalise
    # This module patches `friendly_id` to provide a custom method for
    # normalising slugs. This uses the babosa gem's `normalize` method for
    # better string parameterisation.
    def normalize_friendly_id(input)
      super input.to_s.to_slug.truncate(150).normalize.to_s
    end
  end
end
