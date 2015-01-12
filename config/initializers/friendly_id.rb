FriendlyId.defaults do |config|
  config.base = :name
  config.use :slugged, FriendlyId::SequentialSlugs

  config.sequence_separator = '--'
end
