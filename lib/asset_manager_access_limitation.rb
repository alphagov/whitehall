class AssetManagerAccessLimitation
  def self.for_organisations(item)
    access_limitation = PublishingApi::PayloadBuilder::AccessLimitation.for(item)
    access_limitation.dig(:access_limited, :organisations) || []
  end

  def self.for_users(item)
    access_limitation = PublishingApi::PayloadBuilder::AccessLimitation.for(item)
    access_limitation.dig(:access_limited, :users) || []
  end
end
