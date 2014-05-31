module MainstreamCategoryRoutesHelper
  def mainstream_category_path(category)
    url_for(controller: '/mainstream_categories', action: :show, id: category, parent_tag: category.parent_tag, only_path: true)
  end
end
