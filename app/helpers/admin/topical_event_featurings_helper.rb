module Admin::TopicalEventFeaturingsHelper
  def featurable_offsite_links_for_topical_event(featurable_offsite_links, topical_event)
    @featurable_offsite_links_for_topical_event ||= featurable_offsite_links.reject do |link|
      topical_event.topical_event_featurings.detect do |feature|
        feature.offsite_link == link
      end
    end
  end
end
