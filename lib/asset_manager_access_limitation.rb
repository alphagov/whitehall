class AssetManagerAccessLimitation
  def self.for(item)
    access_limitation = PublishingApi::PayloadBuilder::AccessLimitation.for(item)
    access_limitation[:access_limited][:users]
  end
end
