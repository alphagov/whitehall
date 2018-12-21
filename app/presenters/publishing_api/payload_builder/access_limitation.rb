module PublishingApi
  module PayloadBuilder
    class AccessLimitation
      def self.for(item)
        return {} unless item.access_limited? && !item.publicly_visible?

        users = User.where(organisation: item.organisations)
        { access_limited: { users: users.pluck(:uid).compact } }
      end
    end
  end
end
