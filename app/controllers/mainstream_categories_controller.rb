class MainstreamCategoriesController < PublicFacingController
  layout "specialist"

  def show
    @mainstream_category = MainstreamCategory.find_by_slug(params[:id])
    @specialist_guides = @mainstream_category.published_specialist_guides
  end
end
