class Admin::DocumentSearchesController < Admin::BaseController
  def show
    filter_options = params.slice(:title, :type, :subtypes).merge(state: 'active', per_page: 10)
    @filter = Admin::EditionFilter.new(Edition, current_user, filter_options)
  end
end
