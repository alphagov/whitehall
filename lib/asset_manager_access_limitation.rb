class AssetManagerAccessLimitation
  def self.for(item, type_of_access_limitation)
    access_limitation = PublishingApi::PayloadBuilder::AccessLimitation.for(item)
    access_limitation.dig(:access_limited, type_of_access_limitation)
  end
end
