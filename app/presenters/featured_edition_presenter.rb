class FeaturedEditionPresenter < Draper::Base
  decorates :edition

  attr_reader :edition_organisation

  def initialize(edition_organisation, *args)
    super(edition_organisation.edition, *args)
    @edition_organisation = edition_organisation
  end

  def image_tag(size)
    unless edition_organisation.image.file.url.is_a?(String)
      image_url = edition_organisation.image.file.url(size || :s630)
    else
      image_url = edition_organisation.image.file.url
    end
    h.image_tag image_url, class: 'featured-image', alt: edition_organisation.alt_text
  end
end
