FriendlyId.defaults do |config|
  config.base = :name
  config.use :slugged, :finders, :sequentially_slugged, FriendlyId::CustomNormalise

  config.sequence_separator = '--'
end
