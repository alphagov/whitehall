class PromotionalFeaturesPresenter < Whitehall::Decorators::CollectionDecorator

  def initialize(source, context)
    super(source, PromotionalFeaturePresenter, context)
  end

  def decorated_collection
    build_decorated_collection if @decorated_collection.nil?
    @decorated_collection
  end

  def build_decorated_collection
    position = 0
    @decorated_collection ||= object.map do |feature|
      presenter = decorator_class.new(feature, position, context)
      position += presenter.width
      presenter
    end
  end
end
