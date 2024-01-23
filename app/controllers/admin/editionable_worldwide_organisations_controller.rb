class Admin::EditionableWorldwideOrganisationsController < Admin::EditionsController
  FakeEditionFilter = Struct.new(:editions, :page_title, :show_stats, :hide_type)

  def show
    super

    params[:state] = "active" # Ensure that state column is displayed.
    @paginator = @edition.corporate_information_pages.where("state != ?", "superseded").order("corporate_information_page_type_id").page(params["page"].to_i || 1).per(100)
    @filter = FakeEditionFilter.new @paginator, "Corporate information pages", false, true
  end

private

  def edition_class
    EditionableWorldwideOrganisation
  end
end
