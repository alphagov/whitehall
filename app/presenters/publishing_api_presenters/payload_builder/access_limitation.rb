module PublishingApiPresenters
  module PayloadBuilder
    class AccessLimitation
      def self.for(item)
        return {} unless item.access_limited? && !item.publicly_visible?
        users = User.where(organisation: item.organisations)
        { access_limited: { users: users.map(&:uid).compact } }
      end
    end
  end
end
