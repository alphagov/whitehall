class FeatureListPresenter < Draper::Base
  DEFAULT_FEATURE_LIMIT = 5

  decorates :feature_list

  def initialize(*args)
    super(*args)
    @limit = DEFAULT_FEATURE_LIMIT
  end

  def limit_to(limit)
    @limit = limit
    self
  end

  def current_featured
    feature_list.current.limit(@limit).map do |feature|
      FeaturePresenter.new(feature)
    end
  end

  def current_feature_count
    [feature_list.current.count, @limit].min
  end

  def any_current_features?
    current_feature_count > 0
  end
end
