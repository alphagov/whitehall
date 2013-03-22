class FeaturePresenter < Draper::Base
  decorates :edition

  attr_reader :feature

  def initialize(feature, *args)
    super(feature.document.published_edition, *args)
    @feature = feature
  end

  def image_tag(size)
    image_url = feature.image.url(size || :s630)
    h.image_tag image_url, class: 'featured-image', alt: feature.alt_text
  end
end
