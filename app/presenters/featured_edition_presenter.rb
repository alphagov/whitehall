class FeaturedEditionPresenter < Whitehall::Decorators::Decorator
  delegate_instance_methods_of *Edition.concrete_descendants

  attr_reader :edition_organisation

  def initialize(edition_organisation, context)
    super(edition_organisation.edition, context)
    @edition_organisation = edition_organisation
  end

  def image_tag(size)
    image_url = edition_organisation.image.file.url(size || :s630)
    context.image_tag image_url, class: 'featured-image', alt: edition_organisation.alt_text
  end
end
