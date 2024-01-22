class Admin::EditionableWorldwideOrganisationsController < Admin::EditionsController
  FakeEditionFilter = Struct.new(:editions)

  def show
    super

    editions = @edition.corporate_information_pages.where("state != ?", "superseded").order("corporate_information_page_type_id")
    @filter = FakeEditionFilter.new editions
  end

private

  def edition_class
    EditionableWorldwideOrganisation
  end
end
