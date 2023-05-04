module Admin::FeaturesHelper
  def featurable_offsite_links_for_feature_list(featurable_offsite_links, feature_list)
    @featurable_offsite_links_for_feature_list ||= featurable_offsite_links.reject do |link|
      feature_list.features.current.detect do |feature|
        feature.offsite_link == link
      end
    end
  end
end
