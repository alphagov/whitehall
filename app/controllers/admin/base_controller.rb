class Admin::BaseController < ApplicationController
  include Admin::EditionRoutesHelper

  layout 'admin'
  prepend_before_filter :authenticate_user!
  before_filter :require_signin_permission!
  before_filter :skip_slimmer

  def limit_edition_access!
    forbidden! unless @edition.accessible_by?(current_user)
  end

  def require_fatality_handling_permission!
    forbidden! unless current_user.can_handle_fatalities?
  end

  def require_import_permission!
    authorise_user!(GDS::SSO::Config.default_scope, User::Permissions::IMPORT)
  end

  private

  def forbidden!
    render "admin/editions/forbidden", status: 403
  end
end
