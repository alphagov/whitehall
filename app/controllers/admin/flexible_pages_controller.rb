class Admin::FlexiblePagesController < Admin::EditionsController
  before_action :prevent_access_when_disabled
  def choose_type; end

private

  def edition_class
    FlexiblePage
  end

  def prevent_access_when_disabled
    head :not_found unless Flipflop.flexible_pages?
  end

  def new_edition_params
    # Set the flexible page type for new editions based on the value from the query parameter submitted with the 'choose_type' form
    super[:flexible_page_type].blank? ? super.merge(flexible_page_type: params[:flexible_page_type]) : super
  end
end
