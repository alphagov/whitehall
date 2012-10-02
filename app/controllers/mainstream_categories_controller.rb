class MainstreamCategoriesController < PublicFacingController
  layout "detailed-guidance"

  def show
    if @mainstream_category = MainstreamCategory.find_by_slug_and_parent_tag(params[:id], params[:parent_tag])
      @detailed_guides = @mainstream_category.published_detailed_guides
      breadcrumb_trail = BreadcrumbTrail.for(@mainstream_category)
      set_slimmer_artefact(breadcrumb_trail) if breadcrumb_trail.valid?
    else
      render text: "Not found", status: :not_found
    end
  end
end
