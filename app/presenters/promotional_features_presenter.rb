class PromotionalFeaturesPresenter < Whitehall::Decorators::CollectionDecorator
  def initialize(source, context)
    super(source, PromotionalFeaturePresenter, context)
  end

  def decorated_collection
    position = 0
    @decorated_collection ||= object.map do |feature|
      presenter = decorator_class.new(feature, position, context)
      position += presenter.width
      presenter
    end
  end
end
