class MainstreamCategoriesController < PublicFacingController
  layout "detailed-guidance"

  def show
    @mainstream_category = MainstreamCategory.find_by_slug(params[:id])
    @detailed_guides = @mainstream_category.published_detailed_guides
  end
end
