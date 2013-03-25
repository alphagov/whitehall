class FeatureListPresenter < Draper::Base
  decorates :feature_list

  def current_featured_editions
    feature_list.published_features.limit(5).map do |feature|
      FeaturePresenter.decorate(feature)
    end
  end

  def current_feature_count
    [feature_list.published_features.count, 5].min
  end

  def any_current_features?
    current_feature_count > 0
  end
end
