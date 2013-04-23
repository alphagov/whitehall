class PromotionalFeaturesPresenter
  include Enumerable

  array_methods = Array.instance_methods - Object.instance_methods
  delegate *array_methods, to: :decorated_collection

  def initialize(source)
    position = 0
    @decorated_collection ||= source.collect do |feature|
      presenter = PromotionalFeaturePresenter.new(feature, position: position)
      position += presenter.width
      presenter
    end
  end

  def decorated_collection
    @decorated_collection
  end
end
