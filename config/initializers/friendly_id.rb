FriendlyId.defaults do |config|
  config.base = :name
  config.use :slugged, :finders, FriendlyId::SequentialSlugs

  config.sequence_separator = '--'
end
