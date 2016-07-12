module PublishingApi
  module UpdateTypeHelper
    def default_update_type(item)
      item.minor_change? ? 'minor' : 'major'
    end
  end
end
