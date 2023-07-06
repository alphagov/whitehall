module Admin::FeaturesHelper
  def featurable_offsite_links_for_feature_list(featurable_offsite_links, feature_list)
    @featurable_offsite_links_for_feature_list ||= featurable_offsite_links.reject do |link|
      feature_list.features.current.detect do |feature|
        feature.offsite_link == link
      end
    end
  end

  def featurable_editions_for_feature_list(editions, feature_list)
    @featurable_editions_for_feature_list ||= editions.reject do |edition|
      localised_edition = LocalisedModel.new(edition, feature_list.locale)

      feature_list.features.current.detect do |feature|
        feature.document == localised_edition.document
      end
    end
  end

  def feature_published_on(feature)
    if feature.document&.live_edition.present?
      localize(feature.document.live_edition.major_change_published_at.to_date)
    elsif feature.topical_event.present?
      topical_event_dates_string(feature.topical_event)
    elsif feature.offsite_link.present?
      (localize(feature.offsite_link.date.to_date) if feature.offsite_link.date) || ""
    else
      ""
    end
  end
end
