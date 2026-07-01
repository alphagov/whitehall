module PublishingApi
  module PayloadBuilder
    class AccessLimitation
      def self.for(item)
        return {} unless item.access_limited? && !item.publicly_visible?

        access_limited = {}

        if Flipflop.access_limiting_organisations_ui? && item.respond_to?(:access_limiting_organisations?) && item.access_limiting_organisations?
          access_limited[:organisations] = item.access_limiting_organisations.pluck(:content_id).uniq
        elsif Flipflop.access_limiting_individuals_ui? && item.respond_to?(:access_limiting_individuals?) && item.access_limiting_individuals?
          emails = item.access_limiting_individuals.pluck(:email)

          uids = emails.filter_map { |email|
            User.find_by(email:)&.uid
          }.uniq

          access_limited[:users] = uids unless uids.empty?
        else
          access_limited[:organisations] = item.organisations.pluck(:content_id).uniq
        end

        { access_limited: access_limited }
      end
    end
  end
end
