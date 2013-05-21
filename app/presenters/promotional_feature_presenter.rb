class PromotionalFeaturePresenter < Whitehall::Decorators::Decorator
  delegate_instance_methods_of PromotionalFeature

  attr_reader :position
  def initialize(model, position, context)
    super(model, context)
    @position = position
  end

  def promotional_feature_items
    @promotional_feature_items ||=
      Whitehall::Decorators::CollectionDecorator.new(model.promotional_feature_items,
                                                     PromotionalFeatureItemPresenter,
                                                     context)
  end

  def width
    promotional_feature_items.sum { |item| item.width }
  end

  def width_class
    "features-#{width}"
  end

  def clear_class
    'clear-promo' if (position % 3).zero?
  end

  def css_classes
    ['promo', width_class, clear_class].compact.join(' ')
  end
end
