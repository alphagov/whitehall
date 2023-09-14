class Admin::DocumentCollectionGroupDocumentSearchController < Admin::BaseController
  before_action :check_new_design_system_permissions
  layout :get_layout

  def search_options; end

private

  def check_new_design_system_permissions
    forbidden! unless new_design_system?
  end

  def get_layout
    preview_design_system?(next_release: false) ? "design_system" : "admin"
  end
end
