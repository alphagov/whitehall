class Admin::EditionableWorldwideOrganisationsController < Admin::EditionsController
private

  def edition_class
    EditionableWorldwideOrganisation
  end

  def build_edition_dependencies
    super
    @edition.default_news_image || @edition.build_default_news_image
  end
end
