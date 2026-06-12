module PublishingApi
  module PayloadBuilder
    class AccessLimitation
      def self.for(item)
        return {} unless item.access_limited? && !item.publicly_visible?

        access_limited = {}

        if item.respond_to?(:access_limiting_individuals?) && item.access_limiting_individuals?
          emails = item.access_limiting_individuals.pluck(:email)

          uids = emails.filter_map { |email|
            User.find_by(email:)&.uid
          }.uniq

          access_limited[:users] = uids unless uids.empty?
        else
          organisations = item.organisations.pluck(:content_id).uniq
          access_limited[:organisations] = organisations unless organisations.empty?
        end

        return {} if access_limited.empty?

        { access_limited: access_limited }
      end
    end
  end
end
