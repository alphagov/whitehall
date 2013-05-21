class FeatureListPresenter < Whitehall::Decorators::Decorator
  DEFAULT_FEATURE_LIMIT = 5

  delegate_instance_methods_of FeatureList

  def limit
    @limit || DEFAULT_FEATURE_LIMIT
  end

  def limit_to(limit)
    @limit = limit
    self
  end

  def current_featured
    model.current.limit(limit).map do |feature|
      FeaturePresenter.new(feature)
    end
  end

  def current_feature_count
    [model.current.count, limit].min
  end

  def any_current_features?
    current_feature_count > 0
  end
end
