class FeaturedEditionPresenter < Draper::Base
  decorates :edition

  attr_reader :edition_organisation

  def initialize(edition_organisation, *args)
    super(edition_organisation.edition, *args)
    @edition_organisation = edition_organisation
  end

  def image_tag
    h.image_tag edition_organisation.image.file, class: 'featured-image', alt: edition_organisation.alt_text
  end
end
