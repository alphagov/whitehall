class PromotionalFeaturePresenter < Draper::Base
  decorates :promotional_feature
  decorates_association :promotional_feature_items, with: PromotionalFeatureItemPresenter

  def width
    promotional_feature_items.sum { |item| item.width }
  end

  def position
    options[:position]
  end

  def width_class
    "features-#{width}"
  end

  def clear_class
    'clear-promo' if (position % 3).zero?
  end

  def css_classes
    [width_class, clear_class].compact.join(' ')
  end
end
