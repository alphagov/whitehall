FriendlyId.defaults do |config|
  module CustomNormalisation
    def normalize_friendly_id(input)
      # Use the babosa gem for better string parameterisation
      super input.to_s.to_slug.truncate(150).normalize.to_s
    end
  end

  config.base = :name
  config.use :sequentially_slugged, :finders, CustomNormalisation
  config.sequence_separator = '--'
end
