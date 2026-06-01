module PublishingApi
  module PayloadBuilder
    class AccessLimitation
      def self.for(item)
        return {} unless item.access_limited? && !item.publicly_visible?

        access_limited = {}

        if item.respond_to?(:named_users?) && item.named_users?
          emails = item.edition_user_accesses.pluck(:email)

          uids = emails.filter_map { |email|
            begin
              if Services.signon_api_client.respond_to?(:user_by_email)
                response = Services.signon_api_client.user_by_email(email)
                response && response["uid"]
              end
            rescue StandardError => e
              Rails.logger.error("Signon UID lookup failed for #{email}: #{e.message}")
              nil
            end
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
