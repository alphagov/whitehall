FriendlyId.defaults do |config|
  config.base = :name
  config.use :slugged, Slugging
end
