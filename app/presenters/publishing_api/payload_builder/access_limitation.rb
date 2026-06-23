module PublishingApi
  module PayloadBuilder
    class AccessLimitation
      def self.for(item)
        return {} unless item.access_limited? && !item.publicly_visible?

        organisations = if Flipflop.access_limiting_organisations_ui? && item.access_limiting_organisations?
                          item.access_limiting_organisations.pluck(:content_id).uniq
                        else
                          item.organisations.pluck(:content_id).uniq
                        end

        { access_limited: { organisations: } }
      end
    end
  end
end
