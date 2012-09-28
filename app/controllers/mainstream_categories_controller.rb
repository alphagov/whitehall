class MainstreamCategoriesController < PublicFacingController
  layout "detailed-guidance"

  def show
    @mainstream_category = MainstreamCategory.find_by_slug(params[:id])
    @detailed_guides = @mainstream_category.published_detailed_guides
    breadcrumb_trail = BreadcrumbTrail.for(@mainstream_category)
    set_slimmer_artefact(breadcrumb_trail) if breadcrumb_trail.valid?
  end
end
