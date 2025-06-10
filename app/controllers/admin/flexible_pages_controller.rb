class Admin::FlexiblePagesController < Admin::EditionsController
  before_action :prevent_access_when_disabled
  def new
    render "admin/editions/new" if params.include? :flexible_page_type
  end

private

  def edition_class
    FlexiblePage
  end

  def prevent_access_when_disabled
    head :not_found unless Flipflop.flexible_pages?
  end
end
